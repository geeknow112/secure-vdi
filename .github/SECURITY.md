# Security Policy

## Reporting Security Vulnerabilities

If you discover a security vulnerability in this project, please report it responsibly:

1. **Do NOT** create a public GitHub issue
2. Send an email to [security@example.com] with details
3. Include steps to reproduce the vulnerability
4. Allow reasonable time for response before public disclosure

## Security Considerations

### 🔒 Infrastructure Security

This project creates isolated AWS infrastructure for security research. Key security features:

- **Network Isolation**: Completely isolated VPC with no direct internet access
- **Encryption**: All storage encrypted at rest and in transit
- **Access Control**: IP-restricted access with MFA requirements
- **Monitoring**: Comprehensive logging and audit trails
- **Auto-Cleanup**: Automatic resource deletion to prevent exposure

### ⚠️ Important Security Warnings

1. **IP Restriction**: Always configure `admin_ips` with your specific IP address
2. **Strong Passwords**: Use complex passwords for directory authentication
3. **Temporary Use**: This infrastructure is designed for short-term use only
4. **No Persistent Data**: Do not store sensitive data permanently
5. **Regular Cleanup**: Always run cleanup scripts after use

### 🚨 What NOT to Store in This Repository

- Real AWS credentials or access keys
- Actual IP addresses (use placeholders)
- Production passwords or secrets
- Sensitive research data or findings
- Personal or organizational information

### 🛡️ Safe Usage Guidelines

1. **Fork Privately**: Consider forking to a private repository for actual use
2. **Environment Variables**: Use environment variables for sensitive configuration
3. **Temporary Credentials**: Use temporary AWS credentials when possible
4. **Regular Rotation**: Rotate passwords and access keys regularly
5. **Audit Logs**: Regularly review CloudTrail and VPC Flow Logs

### 📋 Pre-Deployment Checklist

- [ ] Reviewed all configuration files for sensitive data
- [ ] Updated `admin_ips` with your actual IP address
- [ ] Set strong, unique password for directory
- [ ] Configured appropriate auto-cleanup timeframe
- [ ] Verified AWS credentials are properly secured
- [ ] Confirmed understanding of cost implications

### 🔍 Security Scanning

This repository should be regularly scanned for:

- Hardcoded secrets or credentials
- Vulnerable dependencies
- Insecure configurations
- Exposed sensitive information

### 📞 Emergency Response

If you suspect a security breach:

1. Immediately run the cleanup script to destroy infrastructure
2. Rotate all AWS credentials
3. Review CloudTrail logs for unauthorized access
4. Report the incident following your organization's procedures

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Security Updates

Security updates will be released as soon as possible after discovery and verification of vulnerabilities.