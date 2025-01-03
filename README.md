# OS Security Hub

> A comprehensive security auditing and hardening toolkit for multiple operating systems. Features automated compliance checks and security assessment tools based on industry standards and official security guidelines.

### Ubuntu

> Tested on 22.04 LTS (Jammy Jellyfish)

| Version | Released | End of Standard Support | End of Ubuntu Pro Support | End of Legacy Support |
|---|---|---|---|---|
| 22.04 LTS (Jammy Jellyfish) | Apr 2022 | Apr 2027 | Apr 2032 | Apr 2034 |

**240328_CIS_Ubuntu Linux 22.04 LTS Benchmark v2.0.0**

- **Initail Setup**
- [x] (Initial Setup) 1.1.1.1 Ensure cramfs kernel module is not available (Automated)

<br/>

### XenServer

> Tested on XenServer release 8.4.0 (xenenterprise)

| Product | Version | Language | NSC | EOS | EOM & EOL | Notes |
|---|:---:|:---:|:---:|:---:|:---:|---|
| XenServer | 8 | EN | 03-26-2024 | 06-03-2024 | 11-30-2028 | XenServer specific licence required |

- **Account**
- [x] (Account) Default Account Check
- [x] (Account) Root Privilege Account Detection
- [x] (Account) Password File Permission Check
- [x] (Account) Group File Permissions Check
- [x] (Account) Password Policy Check
- [x] (Account) System Account Shell Restriction Check
- [x] (Account) SU Command Restriction Check
- **File System**
- [x] (File System) UMASK Default Configuration Check
- [x] (File System) XSConsole File Permission Check
- [x] (File System) Profile File Permission Check
- [x] (File System) Hosts File Permission Check
- [x] (File System) Issue File Permission Check
- [x] (File System) Dump Command SUID/SGID Permission Check
- [x] (File System) Home Directory and Configuration Files Permission Check
- [x] (File System) Crontab File Permission Check
- [x] (File System) Root PATH Environment Variable Check
- [x] (File System) Service File Permission Check
- **Network and Major App**
- [x] (Network and Major App) Session Timeout Configuration Check
- [x] (Network and Major App) `echo` (7) Service Status Check
- [x] (Network and Major App) `discard` (9) Service Status Check
- [x] (Network and Major App) `daytime` (13) Service Status Check
- [x] (Network and Major App) `chargen` (19) Service Status Check
- [x] (Network and Major App) `time` (37) Service Status Check
- [x] (Network and Major App) `tftp` (69) Service Status Check
- [x] (Network and Major App) `finger` (79) Service Status Check
- [x] (Network and Major App) `sftp` (115) Service Status Check
- [x] (Network and Major App) PAM and SSH Configuration Check for Root Remote Access Control
- **Logging**
- [x] (Logging) Authpriv Log Configuration Check
- [x] (Logging) UDP Syslog Transfer Port (514) Security Check
- [x] (Logging) Audit Log File Permission Check
- [x] (Logging) Failed Login Attempts Log (btmp) Permission Check
- [x] (Logging) XenStore Access Log Permission Check
- [x] (Logging) Secure Log File Permission Check
