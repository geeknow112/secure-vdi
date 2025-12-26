# Contributing to Secure VDI

Thank you for your interest in contributing to the Secure VDI project! This document provides guidelines for contributing safely and effectively.

## 🔒 Security First

Before contributing, please review our [Security Policy](.github/SECURITY.md) and ensure:

- No real credentials, passwords, or sensitive data in commits
- All example configurations use placeholder values
- IP addresses are anonymized (use YOUR.IP.ADDRESS/32)
- Passwords use placeholders (CHANGE_THIS_PASSWORD)

## 🚀 Getting Started

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Make your changes
4. Test your changes thoroughly
5. Run security scans locally
6. Submit a pull request

## 🧪 Testing

### Local Testing

Before submitting a PR, test your changes:

```bash
# Terraform validation
cd terraform
terraform init -backend=false
terraform validate
terraform fmt -check -recursive

# Security scan
gitleaks detect --source . --verbose

# Checkov scan
checkov -d terraform/ --framework terraform
```

### Required Tests

- [ ] Terraform configuration validates
- [ ] No hardcoded secrets detected
- [ ] Documentation updated
- [ ] Example files use placeholders only

## 📝 Pull Request Guidelines

### PR Title Format
```
type(scope): description

Examples:
feat(terraform): add CloudWatch monitoring
fix(security): update security group rules
docs(readme): improve setup instructions
```

### PR Description Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Security improvement

## Security Checklist
- [ ] No real credentials in code
- [ ] Placeholder values used in examples
- [ ] Security scan passed locally
- [ ] Sensitive data properly excluded

## Testing
- [ ] Terraform validate passed
- [ ] Local testing completed
- [ ] Documentation updated

## Additional Notes
Any additional context or notes
```

## 🛡️ Security Guidelines

### What to Include
- Infrastructure as Code improvements
- Security enhancements
- Documentation improvements
- Bug fixes
- Performance optimizations

### What NOT to Include
- Real AWS credentials or keys
- Actual IP addresses
- Production passwords
- Sensitive research data
- Personal information

### Sensitive Data Handling
- Use environment variables for secrets
- Reference external credential stores
- Provide clear setup instructions
- Include security warnings

## 📋 Code Standards

### Terraform
- Use consistent naming conventions
- Include proper resource tags
- Add variable descriptions
- Validate input parameters
- Follow HashiCorp style guide

### Shell Scripts
- Use bash strict mode (`set -e`)
- Include error handling
- Add colored output for clarity
- Validate prerequisites
- Include usage instructions

### Documentation
- Keep README up to date
- Include security considerations
- Provide clear examples
- Document all variables
- Add troubleshooting guides

## 🔍 Review Process

1. **Automated Checks**: All PRs run security scans and validation
2. **Manual Review**: Maintainers review for security and quality
3. **Testing**: Changes tested in isolated environment
4. **Approval**: Requires approval from project maintainers

## 🐛 Bug Reports

When reporting bugs:

1. Use the bug report template
2. Include steps to reproduce
3. Provide environment details
4. Remove any sensitive information
5. Include relevant logs (sanitized)

## 💡 Feature Requests

For new features:

1. Check existing issues first
2. Describe the use case clearly
3. Consider security implications
4. Propose implementation approach
5. Discuss with maintainers first

## 📞 Getting Help

- Create an issue for questions
- Join discussions in existing issues
- Review documentation thoroughly
- Check security guidelines

## 🏆 Recognition

Contributors will be recognized in:
- README contributors section
- Release notes
- Project documentation

Thank you for helping make Secure VDI better and more secure! 🙏