#!/usr/bin/env bash

set -e

ARGO_APP_NAME="redis-assignment"

echo
echo "========================================"
echo " Redis Assignment - Argo CD Cleanup"
echo "========================================"
echo

if kubectl get application \
    "${ARGO_APP_NAME}" \
    -n argocd >/dev/null 2>&1; then

    echo "Deleting Argo CD Application '${ARGO_APP_NAME}'..."

    kubectl delete application \
        "${ARGO_APP_NAME}" \
        -n argocd

else

    echo "Argo CD Application '${ARGO_APP_NAME}' does not exist."

fi

echo
echo "========================================"
echo " Application cleanup complete"
echo "========================================"
echo
echo "The kind cluster was NOT deleted."
echo "NGINX Ingress Controller was NOT deleted."
echo "Argo CD itself was NOT deleted."
echo