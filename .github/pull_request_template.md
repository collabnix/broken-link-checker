## Description

Briefly describe the changes in this pull request.

## Type of Change

- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update
- [ ] Docker/CI improvements
- [ ] Performance improvement
- [ ] Code refactoring

## Testing

### Local Testing
- [ ] Tested locally with Python
- [ ] Tested with Docker build
- [ ] Tested with docker-compose
- [ ] Ran the test script: `./scripts/test-image.sh`
- [ ] Verified MCP tool functionality

### CI/CD Testing
- [ ] GitHub Actions build passes
- [ ] Docker multi-platform build works
- [ ] Security scan passes
- [ ] All automated tests pass

## Checklist

### Code Quality
- [ ] Code follows the project's style guidelines
- [ ] Self-review of code completed
- [ ] Code is well-commented, particularly in hard-to-understand areas
- [ ] No unnecessary console.log or debug statements

### Documentation
- [ ] Updated README.md if needed
- [ ] Updated Docker documentation if applicable
- [ ] Added/updated inline code comments
- [ ] Updated examples if functionality changed

### Docker Changes (if applicable)
- [ ] Dockerfile builds successfully
- [ ] Docker image size is reasonable
- [ ] Multi-platform support maintained (amd64/arm64)
- [ ] Security best practices followed
- [ ] Health checks work properly
- [ ] Volume mounts and configurations tested

### MCP Changes (if applicable)
- [ ] MCP server starts without errors
- [ ] All tools are properly registered
- [ ] Tool parameters are correctly defined
- [ ] Error handling is appropriate
- [ ] Compatible with existing MCP clients

## Screenshots/Output

If applicable, add screenshots or command output to demonstrate the changes.

```bash
# Example command output
$ ./scripts/test-image.sh
✅ Dependencies OK
✅ MCP server import OK
```

## Related Issues

Fixes #(issue number)
Related to #(issue number)

## Additional Notes

Any additional information that reviewers should know about this PR.

## Reviewer Notes

For reviewers:
- [ ] Code review completed
- [ ] Docker build tested locally
- [ ] Functionality verified
- [ ] Documentation reviewed
- [ ] Security considerations checked