#!/bin/bash

# Need to install cli and login
# https://cli.github.com/manual/gh_secret_set
# https://github.com/cli/cli/blob/trunk/docs/install_linux.md
# gh auth login

gh secret set -f scripts/.env
