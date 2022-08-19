#!/usr/bin/env bash

set -euo pipefail

cask_name="${1}"
cask_path="./Casks/${cask_name}-halyard.rb"
cask_url="$(brew cask _stanza url "${cask_path}")"

echo "${cask_url}"
curl --fail -sL "$cask_url" | sha256sum | cut -d' ' -f1
