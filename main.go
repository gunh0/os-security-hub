package main

import (
	"log"

	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"

	"github.com/gunh0/os-security-hub/api/handlers"
	_ "github.com/gunh0/os-security-hub/docs"
)

// @title OS Security Hub API
// @version 1.0
// @description Security compliance scanning and monitoring system for multiple operating systems
// @contact.name API Support
// @contact.email your-email@example.com
// @license.name Apache 2.0
// @license.url http://www.apache.org/licenses/LICENSE-2.0.html
// @host localhost:8080
// @BasePath /api
func main() {
	r := setupRouter()

	if err := r.Run(":8080"); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}

func setupRouter() *gin.Engine {
	r := gin.New()

	// Middleware
	r.Use(gin.Logger())
	r.Use(gin.Recovery())

	// Swagger
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	v1 := r.Group("/api/")
	{
		// Health Check
		v1.GET("/health", handlers.HealthCheck)
	}

	return r
}
