#!/bin/bash
set -euo

KUBEVAL_VERSION="v0.16.1"
echo "Using Kubeval Version: ${KUBEVAL_VERSION}"

SCHEMA_LOCATION="https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/"
echo "Using Schema Location: ${SCHEMA_LOCATION}"

CHART_DIRS="$(git diff --find-renames --name-only "$(git rev-parse --abbrev-ref HEAD)" remotes/origin/master -- charts | grep '[cC]hart.yaml' | sed -e 's#/[Cc]hart.yaml##g')"
if [ -z "$CHART_DIRS" ]
then
      echo "Chart Directory is empty. Please check if you increased the Chart version."
      exit 1
fi

# install kubeval
curl --silent --show-error --fail --location --output /tmp/kubeval.tar.gz https://github.com/instrumenta/kubeval/releases/download/"${KUBEVAL_VERSION}"/kubeval-linux-amd64.tar.gz
tar -xf /tmp/kubeval.tar.gz kubeval

echo "Downloaded and unpacked kubeval successfully"

# validate charts
for CHART_DIR in ${CHART_DIRS}; do
  helm template "${CHART_DIR}" --debug | ./kubeval --ignore-missing-schemas --kubernetes-version "${KUBERNETES_VERSION#v}" --schema-location "${SCHEMA_LOCATION}"
done
