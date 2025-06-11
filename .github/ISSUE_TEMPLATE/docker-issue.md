---
name: Docker Issue
about: Report issues related to Docker images or containers
title: '[DOCKER] '
labels: docker
assignees: ''

---

**Docker Environment**
- Docker version: [e.g. 20.10.17]
- Docker Compose version: [e.g. 2.6.0]
- Operating System: [e.g. Ubuntu 22.04, macOS 13.0, Windows 11]
- Architecture: [e.g. amd64, arm64]

**Image Information**
- Image tag: [e.g. collabnix/broken-link-checker-mcp:latest]
- Pull method: [e.g. docker pull, docker-compose, build locally]

**Issue Description**
A clear and concise description of what the issue is.

**Steps to Reproduce**
1. Run command: `docker run ...`
2. See error: '...'
3. Check logs: `docker logs ...`

**Expected Behavior**
A clear and concise description of what you expected to happen.

**Actual Behavior**
A clear and concise description of what actually happened.

**Logs**
```
# Container logs
docker logs [container-name]

# Docker Compose logs
docker-compose logs
```

**Configuration Files**
If applicable, add your docker-compose.yml or MCP configuration:

```yaml
# docker-compose.yml or relevant config
```

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Additional Context**
- Are you using the image in production or development?
- Any custom configurations or modifications?
- Network or firewall restrictions?
- Resource constraints (memory, CPU)?

**Troubleshooting Attempted**
- [ ] Pulled latest image
- [ ] Checked container logs
- [ ] Verified Docker/Docker Compose installation
- [ ] Tested with different image tag
- [ ] Checked resource usage
- [ ] Reviewed documentation

**Possible Solution**
If you have an idea of what might be causing the issue or how to fix it, please describe it here.