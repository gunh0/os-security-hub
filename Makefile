.PHONY: dev run swag tidy

# Global variables
APP_NAME=os-security-hub

# Development with air (hot-reload)
dev:
	@go mod tidy
	@swag init
	@if ! command -v air > /dev/null; then \
		echo "Installing air..."; \
		go install github.com/cosmtrek/air@latest; \
	fi
	@echo "Starting development server with air..."
	air

# Regular run
run:
	@echo "Building and running $(APP_NAME)..."
	@swag init
	@go run main.go

# Generate swagger docs
swag:
	@echo "Generating Swagger documentation..."
	@swag init

# Update dependencies
tidy:
	@echo "Tidying up dependencies..."
	@go mod tidy

# Run audit script
# Usage)
# make test-audit SCRIPT=dangerous_or_unnecessary_account_detection CATEGORY=account
# make test-audit SCRIPT=root_privilege_account_detection CATEGORY=account
# make test-audit SCRIPT=password_policy_check CATEGORY=account
# make test-audit SCRIPT=system_account_shell_restriction_check CATEGORY=account
HOST=172.16.0.205
USERNAME=root
PASSWORD=1q2w3e4r!!Q
test-audit:
	@echo "Running audit script: $(SCRIPT)"
	@curl -X 'POST' \
		'http://localhost:8080/api/audit/run' \
		-H 'accept: application/json' \
		-H 'Content-Type: application/json' \
		-d '{"category":"$(CATEGORY)","host":"$(HOST)","password":"$(PASSWORD)","script":"$(SCRIPT)","username":"$(USERNAME)"}' | json_pp