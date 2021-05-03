#!/bin/bash
set -euo pipefail

echo 'test'

ls -la

KUBEVAL_VERSION="v0.16.1"
echo KUBEVAL_VERSION
echo KUBERNETES_VERSION

SCHEMA_LOCATION="https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/"
echo SCHEMA_LOCATION

CHART_DIRS="$(git diff --find-renames --name-only "$(git rev-parse --abbrev-ref HEAD)" remotes/origin/master -- charts | grep '[cC]hart.yaml' | sed -e 's#/[Cc]hart.yaml##g')"
echo CHART_DIRS

# install kubeval
curl --silent --show-error --fail --location --output /tmp/kubeval.tar.gz https://github.com/instrumenta/kubeval/releases/download/"${KUBEVAL_VERSION}"/kubeval-linux-amd64.tar.gz
tar -xf /tmp/kubeval.tar.gz kubeval

ls -la
echo CHART_DIRS

# validate charts
for CHART_DIR in ${CHART_DIRS}; do
  echo CHART_DIR
  helm template "${CHART_DIR}" --debug | ./kubeval --ignore-missing-schemas --kubernetes-version "${KUBERNETES_VERSION#v}" --schema-location "${SCHEMA_LOCATION}"
done
