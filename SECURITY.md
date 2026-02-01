# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| Latest  | ✅        |

## Reporting a Vulnerability

If you discover a security vulnerability in this project, please report it responsibly:

1. **Do NOT open a public issue** - This could expose the vulnerability to attackers
2. **Report via Private Channel**:
   - GitHub Security Advisories: https://github.com/yourusername/secoc/security/advisories
   - Email: security@example.com (replace with actual contact)

Include the following information in your report:
- Type of vulnerability (XSS, SQLi, etc.)
- Affected version(s)
- Steps to reproduce
- Potential impact
- Suggested fix (if known)

## Response Timeline

- **Initial Response**: Within 48 hours
- **Analysis**: 3-7 days
- **Fix Release**: Based on severity (Critical: 24-48h, High: 3-7 days, Medium: 2 weeks)

## Security Best Practices for secoc

### Container Security

This project implements several security measures:

1. **Non-root User**: Container runs as non-root user (UID/GID configurable)
2. **GPG Signature Verification**: Adoptium Java packages verified with known fingerprints
3. **Checksum Verification**: Bun and OpenCode downloads verified with SHA256
4. **Minimal Base Image**: Uses Debian Bookworm Slim
5. **No Passwords in Image**: All secrets via build args or volume mounts

### Build-Time Security

```bash
# Use custom UID/GID matching your host system
podman build \
  --build-arg UID=$(id -u) \
  --build-arg GID=$(id -g) \
  --tag secoc:latest .
```

### Runtime Security

```bash
# Optional: Add security flags
podman run -it --rm \
  --security-opt no-new-privileges \
  --read-only \
  --tmpfs /tmp \
  --cap-drop ALL \
  --cap-add NET_BIND_SERVICE \
  secoc:latest
```

### Known Limitations

- **OpenCode CLI Releases**: No checksum files available - warning shown during build
- **SSH Keys**: Mounted by default for Git operations - consider `--no-ssh` flag in production
- **Network Mode**: Uses `--network host` by default - consider `--network bridge` for production

## Recent Security Improvements

### Phase 1: Critical Fixes (Implemented)
- ✅ Bun installation via GitHub Releases with SHA256 verification
- ✅ Adoptium GPG fingerprint verification
- ✅ Command injection validation in seccode script
- ✅ Path normalization and validation
- ✅ GitHub API rate limiting and retries
- ✅ Replaced `eval` with `source` in Dockerfile

### Phase 2: High Priority (Implemented)
- ✅ GitHub workflow permissions restricted per job
- ✅ UID/GID customization via build args
- ✅ Security labels added to container image
- ✅ Branch protection requirements documented

### Phase 3: Medium Priority (Recommended)
- ⏳ Consider `--network bridge` instead of `--network host`
- ⏳ Optional SSH/Git mount flags
- ⏳ Dependency version pinning in workflows

### Phase 4: Low Priority (Future)
- ⏳ GPG-signed releases
- ⏳ Automated vulnerability scanning in CI
- ⏳ SBOM generation

## Security Scanning

We recommend running security scans before deployment:

```bash
# Trivy scan
trivy image secoc:latest

# Grype scan
grype secoc:latest

# Docker Scout (if using Docker Hub)
docker scout cves secoc:latest
```

## Additional Resources

- [Dockerfile Security Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Container Security Checklist](https://snyk.io/blog/10-docker-image-security-best-practices/)
- [CWE/SANS Top 25](https://cwe.mitre.org/top25/)
