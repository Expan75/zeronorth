# Zero North Interview challenge

This repo covers the Zero North Terraform interview question

# Gettings started

### Dependencies

- [Terraform v1.9.8](https://www.terraform.io/)
- [GitHub CLI v2.62.0](https://cli.github.com/)

### First-time setup

1. Configure your remote backend. All environmnets rely on a remote storage backend (Cloudflare R2 in this case). Typically, it makes sense to use your primary Cloud provider but here we save time by resuing another project's cloudflare R2 setup. An example configuration with R2 is seen below, assuming bucket and access key has been set up. This bucket contain (encryted hopfully) all of terraform state; including sensitive details like credentials and API keys. Access to this bucket should be heavily restricted. Mind you that the setup for S3 is almost identical.

```bash
# optional quality of life
echo "alias tf=terraform" >> ~/.zshrc   # for zsh
echo "alias tf=terraform" >> ~/.bashrc  # for bash

# copy the example backend defintion; don't risk commit it to the repo by using some over directory.
cd ./services/challenge/terraform && cp backend.example.conf ~/.backend.conf

# fill it with the details and double check that its not added to VC.
vim ~/.backend.conf

# ensure you're in services/challenge/terraform
pwd

# initalise terraform
tf init -backend-config=~/.backend.conf
```

### Local Development

Local development in Terraform differs from that of most code as the runtime is the cloud by definition. We use a "personal" environment to denote that it is not inside the development environment (latest green build) or the production environment (latest release). Primarily this is to ensure that the deployment process is protected (limited blast of 'tf destroy') and automated (via github action).

### Testing

Testing in terraform is a topic in and of itself. Here we test and develop in our personal environment but do not write tests (primarily because we're out of time). That said, there does exist tests for our service application code (in python) and instructions for how to trigger the deployed lambda in your personal environment (see services/challenge/README.md for details).

### Q/A

We use [tflint](https://github.com/terraform-linters/tflint). The CI/CD pipeline will reject non-compliant terraform.

```bash
# install
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash   # on linux
brew install tflint                                                                                 # on mac
choco install tflint                                                                                # on windows

# run linter in a terraform module
cd ./services/challenge/terraform && tflint
```

# Deployment

### Environments

We use 3 seperate environments:

- personal: local development and testing, manually deployed via operator running apply
- development: latest green build automatically deployed via CI/CD
- production: latest release

### Secrets

In real life setting we'd use a secret manager like AWS's SSM. In this case we're strapped for time so we willingly forgo what should be a neccecity in any real project. In this case, the only secrets available are those in your backend.conf (which should not be VC:ed) and those existing in the CI/CD pipeline (on GitHub). We use terraform to create these CI/CD secrets (workflow secrets) but manually fill them in the web gui of GitHub.

### CI/CD

All non-personal environment deployments are done automatically by CI/CD in the form of GitHub actions. See See .github/workflows for the definitions of the pipelines.

### Deploying to non-personal environments (development, production)

- Deployment to the development environment occurs automatically whenever a green build passes CI/CD.
- Deployment to the development environment occurs automatically whenever a release via git tag is pushed to main.
