package handlers

import (
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/gunh0/os-security-hub/pkg/ssh"
)

type AuditRequest struct {
	Host     string `json:"host" binding:"required"`
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
	Category string `json:"category" binding:"required,oneof=account filesystem network hypervisor patch_and_log"`
	Script   string `json:"script" binding:"required"`
}

type AuditResult struct {
	Title     string    `json:"title"`
	Result    string    `json:"result"`
	Details   string    `json:"details"`
	Timestamp time.Time `json:"timestamp"`
}

// ErrorResponse represents an error response from the API
type ErrorResponse struct {
	Error string `json:"error" example:"error message"`
}

// RunAudit godoc
// @Summary Run audit script on remote server
// @Description Execute security audit script on remote server
// @Tags audit
// @Accept json
// @Produce json
// @Param request body AuditRequest true "Audit execution request"
// @Success 200 {object} AuditResult
// @Failure 400,500 {object} ErrorResponse
// @Router /audit/run [post]
func RunAudit(c *gin.Context) {
	var req AuditRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, ErrorResponse{
			Error: err.Error(),
		})
		return
	}

	client, err := ssh.NewClient(req.Host, req.Username, req.Password)
	if err != nil {
		c.JSON(http.StatusInternalServerError, ErrorResponse{
			Error: "Failed to establish SSH connection: " + err.Error(),
		})
		return
	}
	defer client.Close()

	scriptPath := fmt.Sprintf("audit/xenserver/%s/%s.sh", req.Category, req.Script)
	output, err := client.ExecuteScript(scriptPath)
	if err != nil {
		c.JSON(http.StatusInternalServerError, ErrorResponse{
			Error: "Script execution failed: " + err.Error(),
		})
		return
	}

	var result AuditResult
	if err := json.Unmarshal([]byte(output), &result); err != nil {
		c.JSON(http.StatusInternalServerError, ErrorResponse{
			Error: "Failed to parse script output: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, result)
}
