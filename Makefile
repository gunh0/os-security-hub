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
# e.g target server)
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

# Usage)
test-audit-account-01:
	@make test-audit SCRIPT=default_account_check CATEGORY=account

test-audit-account-02:
	@make test-audit SCRIPT=root_privilege_account_detection CATEGORY=account

test-audit-account-03:
	@make test-audit SCRIPT=password_file_permission_check CATEGORY=account

test-audit-account-04:
	@make test-audit SCRIPT=group_file_permission_check CATEGORY=account

test-audit-account-05:
	@make test-audit SCRIPT=password_policy_check CATEGORY=account

test-audit-account-06:
	@make test-audit SCRIPT=system_account_shell_restriction_check CATEGORY=account

test-audit-account-07:
	@make test-audit SCRIPT=su_command_restriction_check CATEGORY=account

test-audit-file-01:
	@make test-audit SCRIPT=umask_default_configuration_check CATEGORY=file_system

test-audit-file-02:
	@make test-audit SCRIPT=xsconsole_file_permission_check CATEGORY=file_system

test-audit-file-03:
	@make test-audit SCRIPT=profile_file_permission_check CATEGORY=file_system

test-audit-file-04:
	@make test-audit SCRIPT=hosts_file_permission_check CATEGORY=file_system

test-audit-network-01:
	@make test-audit SCRIPT=session_timeout_configuration_check CATEGORY=network_and_app

test-audit-logging-01:
	@make test-audit SCRIPT=authpriv_log_configuration_check CATEGORY=logging

test-audit-logging-02:
	@make test-audit SCRIPT=udp_syslog_transfer_port_security_check CATEGORY=logging

test-audit-logging-03:
	@make test-audit SCRIPT=audit_log_file_permission_check CATEGORY=logging