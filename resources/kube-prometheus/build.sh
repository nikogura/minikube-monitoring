#!/usr/bin/env bash

# This script uses arg $1 (name of *.jsonnet file to use) to generate the generated/*.yaml files.

set -e
set -x
# only exit with zero if all commands of the pipeline exit successfully
set -o pipefail

# Make sure to use project tooling
PATH="$(pwd)/tmp/bin:${PATH}"

# Make sure to start with a clean 'generated' dir
rm -rf generated
mkdir -p generated/setup

# Calling gojsontoyaml is optional, but we would like to generate yaml, not json
jsonnet -J vendor -m generated "${1-minikube.jsonnet}" | xargs -I{} sh -c 'cat {} | gojsontoyaml > {}.yaml' -- {}

# Make sure to remove json files
find generated -type f ! -name '*.yaml' -delete
rm -f kustomization

