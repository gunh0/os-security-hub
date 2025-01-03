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
UBUNTU_HOST=172.16.0.191
UBUNTU_USERNAME=ian
UBUNTU_PASSWORD=1
test-audit-ubuntu:
	@echo "Running audit script: $(SCRIPT)"
	@curl -X 'POST' \
		'http://localhost:8080/api/audit/run' \
		-H 'accept: application/json' \
		-H 'Content-Type: application/json' \
		-d '{"os":"$(OS)","host":"$(UBUNTU_HOST)","username":"$(UBUNTU_USERNAME)","password":"$(UBUNTU_PASSWORD)","category":"$(CATEGORY)","script":"$(SCRIPT)"}' | json_pp

test-audit-ubuntu-setup-01:
	@make test-audit-ubuntu OS=ubuntu CATEGORY=initial_setup SCRIPT=ensure_cramfs_kernel_module_is_not_available

# Run audit script
# e.g target server)
XEN_HOST=172.16.0.205
XEN_USERNAME=root
XEN_PASSWORD=1q2w3e4r!!Q
test-audit-xen:
	@echo "Running audit script: $(SCRIPT)"
	@curl -X 'POST' \
		'http://localhost:8080/api/audit/run' \
		-H 'accept: application/json' \
		-H 'Content-Type: application/json' \
		-d '{"os":"$(OS)","host":"$(XEN_HOST)","username":"$(XEN_USERNAME)","password":"$(XEN_PASSWORD)","category":"$(CATEGORY)","script":"$(SCRIPT)"}' | json_pp

# XenServer Usage (Account))
test-audit-xen-account-01:
	@make test-audit-xen OS=xenserver CATEGORY=account SCRIPT=default_account_check 

test-audit-xen-account-02:
	@make test-audit-xen OS=xenserver CATEGORY=account SCRIPT=root_privilege_account_detection

test-audit-xen-account-03:
	@make test-audit-xen OS=xenserver CATEGORY=account SCRIPT=password_file_permission_check

test-audit-xen-account-04:
	@make test-audit-xen OS=xenserver CATEGORY=account SCRIPT=group_file_permission_check 

test-audit-xen-account-05:
	@make test-audit-xen OS=xenserver CATEGORY=account SCRIPT=password_policy_check

test-audit-xen-account-06:
	@make test-audit-xen OS=xenserver CATEGORY=account SCRIPT=system_account_shell_restriction_check

test-audit-xen-account-07:
	@make test-audit-xen OS=xenserver CATEGORY=account SCRIPT=su_command_restriction_check

# XenServer Usage (File System))
test-audit-xen-file-01:
	@make test-audit-xen OS=xenserver CATEGORY=file_system SCRIPT=umask_default_configuration_check

test-audit-xen-file-02:
	@make test-audit-xen OS=xenserver CATEGORY=file_system SCRIPT=xsconsole_file_permission_check

test-audit-xen-file-03:
	@make test-audit-xen OS=xenserver CATEGORY=file_system SCRIPT=profile_file_permission_check

test-audit-xen-file-04:
	@make test-audit-xen OS=xenserver CATEGORY=file_system SCRIPT=hosts_file_permission_check

test-audit-xen-file-20:
	@make test-audit-xen OS=xenserver CATEGORY=file_system SCRIPT=home_directory_and_configuration_files_permission_check

test-audit-xen-file-21:
	@make test-audit-xen OS=xenserver CATEGORY=file_system SCRIPT=crontab_file_permission_check

test-audit-xen-file-35:
	@make test-audit-xen OS=xenserver CATEGORY=file_system SCRIPT=root_path_environment_variable_check

test-audit-xen-file-36:
	@make test-audit-xen OS=xenserver CATEGORY=file_system SCRIPT=service_file_permission_check

# XenServer Usage (Network and Major App))
test-audit-xen-network-01:
	@make test-audit-xen OS=xenserver CATEGORY=network_and_app SCRIPT=session_timeout_configuration_check

test-audit-xen-network-02:
	@make test-audit-xen OS=xenserver CATEGORY=network_and_app SCRIPT=echo_service_status_check

test-audit-xen-network-03:
	@make test-audit-xen OS=xenserver CATEGORY=network_and_app SCRIPT=discard_service_status_check

test-audit-xen-network-04:
	@make test-audit-xen OS=xenserver CATEGORY=network_and_app SCRIPT=daytime_service_status_check

test-audit-xen-network-05:
	@make test-audit-xen OS=xenserver CATEGORY=network_and_app SCRIPT=chargen_service_status_check

test-audit-xen-network-06:
	@make test-audit-xen OS=xenserver CATEGORY=network_and_app SCRIPT=time_service_status_check

test-audit-xen-network-07:
	@make test-audit-xen OS=xenserver CATEGORY=network_and_app SCRIPT=tftp_service_status_check

test-audit-xen-network-08:
	@make test-audit-xen OS=xenserver CATEGORY=network_and_app SCRIPT=finger_service_status_check

test-audit-xen-network-09:
	@make test-audit-xen OS=xenserver CATEGORY=network_and_app SCRIPT=sftp_service_status_check

test-audit-xen-network-28:
	@make test-audit-xen OS=xenserver CATEGORY=network_and_app SCRIPT=pam_adn_ssh_configuration_check_for_root_remote_access_control

# XenServer Usage (Logging))
test-audit-xen-logging-01:
	@make test-audit-xen OS=xenserver CATEGORY=logging SCRIPT=authpriv_log_configuration_check 

test-audit-xen-logging-02:
	@make test-audit-xen OS=xenserver CATEGORY=logging SCRIPT=udp_syslog_transfer_port_security_check

test-audit-xen-logging-03:
	@make test-audit-xen OS=xenserver CATEGORY=logging SCRIPT=audit_log_file_permission_check

test-audit-xen-logging-04:
	@make test-audit-xen OS=xenserver CATEGORY=logging SCRIPT=btmp_permission_check

test-audit-xen-logging-05:
	@make test-audit-xen OS=xenserver CATEGORY=logging SCRIPT=xenstore_access_log_permission_check

test-audit-xen-logging-06:
	@make test-audit-xen OS=xenserver CATEGORY=logging SCRIPT=secure_log_file_permission_check