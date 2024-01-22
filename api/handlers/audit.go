// api/handlers/audit.go
package handlers

import (
	"encoding/json"
	"fmt"
	"net/http"
	"path/filepath"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/gunh0/os-security-hub/pkg/ssh"
)

type AuditRequest struct {
	Host     string `json:"host" binding:"required"`
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
	OS       string `json:"os" binding:"required,oneof=ubuntu xenserver"` // OS 타입 추가
	Category string `json:"category" binding:"required"`                  // 카테고리 검증 제거
	Script   string `json:"script" binding:"required"`
}

type AuditResult struct {
	Title     string    `json:"title"`
	Result    string    `json:"result"`
	Details   string    `json:"details"`
	Timestamp time.Time `json:"timestamp"`
}

type ErrorResponse struct {
	Error string `json:"error" example:"error message"`
}

// getScriptPath returns the appropriate script path based on OS and category
func getScriptPath(os, category, script string) string {
	switch os {
	case "ubuntu":
		return filepath.Join("audit", "ubuntu", category, script+".sh")
	case "xenserver":
		return filepath.Join("audit", "xenserver", category, script+".sh")
	default:
		return ""
	}
}

// validateCategory checks if the category is valid for the given OS
func validateCategory(os, category string) error {
	validCategories := map[string][]string{
		"ubuntu":    {"initial_setup"},
		"xenserver": {"account", "file_system", "network_and_app", "logging"},
	}

	if categories, ok := validCategories[os]; ok {
		for _, validCategory := range categories {
			if category == validCategory {
				return nil
			}
		}
		return fmt.Errorf("invalid category '%s' for OS '%s'", category, os)
	}
	return fmt.Errorf("unsupported OS: %s", os)
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

	// Validate category for the specified OS
	if err := validateCategory(req.OS, req.Category); err != nil {
		c.JSON(http.StatusBadRequest, ErrorResponse{
			Error: err.Error(),
		})
		return
	}

	// Get script path based on OS and category
	scriptPath := getScriptPath(req.OS, req.Category, req.Script)
	if scriptPath == "" {
		c.JSON(http.StatusBadRequest, ErrorResponse{
			Error: "Invalid OS specified",
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
