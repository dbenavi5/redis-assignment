#!/usr/bin/env bash

set -e

RELEASE_NAME="redis-assignment"

echo
echo "========================================"
echo " Redis Assignment - Helm Cleanup"
echo "========================================"
echo

if helm status "${RELEASE_NAME}" >/dev/null 2>&1; then

    echo "Uninstalling Helm release '${RELEASE_NAME}'..."

    helm uninstall "${RELEASE_NAME}"

else

    echo "Helm release '${RELEASE_NAME}' is not installed."

fi

echo
echo "========================================"
echo " Application cleanup complete"
echo "========================================"
echo
echo "The kind cluster was NOT deleted."
echo "The NGINX Ingress Controller was NOT deleted."
echo