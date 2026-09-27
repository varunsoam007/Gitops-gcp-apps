#!/usr/bin/env bash
set -e

REGISTRY="${1:-oci://registry-1.docker.io/varunsoam}"
CHART_DIR="$(dirname "$0")/charts/global-templates"

echo "Packaging global-templates from ${CHART_DIR}..."
PACKAGE_OUTPUT=$(helm package "${CHART_DIR}")
ARCHIVE=$(echo "${PACKAGE_OUTPUT}" | awk -F': ' '{print $2}')

echo "Packaged chart: ${ARCHIVE}"
echo "Pushing to ${REGISTRY}..."
helm push "${ARCHIVE}" "${REGISTRY}"

echo "Successfully pushed ${ARCHIVE} to ${REGISTRY}!"
