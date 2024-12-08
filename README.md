# Zero North Interview challenge

This repo covers the Zero North Terraform interview question

# Gettings started

### Dependencies

- [Terraform v1.9.8](https://www.terraform.io/)
- [GitHub CLI v2.62.0](https://cli.github.com/)

### First-time setup

1. Configure your remote backend. All environmnets rely on a remote storage backend (AWS S3 in this case). Typically, it makes sense to use your primary Cloud provider. An example configuration with S3 is seen below, assuming bucket and access key has been set up. This bucket contain (encryted hopfully) all of terraform state; including sensitive details like credentials and API keys. Access to this bucket should be heavily restricted.

```bash
tf init -backend-config=backend.conf
aws
```

### Local Development

### Testing

### Q/A

# Deployment

### Environments

In a realistic setting, a production environment is most likely proceeded by several other environments (dev, staging, user-acceptance etc.); to limit the scope of the interview question, only local development, cloud development, and a production environmnet is used (i.e. 2 deployment target environment).

### CI/CD

All deployment and integration is done automatically via Github action. See .github/workflows for the definitions of the pipelines.

### Deploying to development

Deployment to the development environment occurs automatically whenever a green bui

### Deploying to production

Deployment

### Secrets

### CI/CD
