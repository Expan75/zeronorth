# challenge

### Dependencies

- [rye](https://rye.astral.sh/)

### Getting started

```Bash
# install packages
rye sync

# run tests
rye test
```

To test the infrastructure and deployment, use a personal AWS environment and run:

```Bash
tf plan         # see the changes to be made
tf apply        # make the changes
tf destroy      # cleanup your environment
```

### Deployment

Handled by CI/CD via Terraform. See root README.md for instructions.
