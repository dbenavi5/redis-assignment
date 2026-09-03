#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
K8S_DIR="${PROJECT_ROOT}/k8s"

echo
echo "========================================"
echo " Redis Assignment - Application Cleanup"
echo "========================================"
echo

echo "Deleting FastAPI Service..."
kubectl delete -f "${K8S_DIR}/service.yaml" --ignore-not-found

echo
echo "Deleting FastAPI Deployment..."
kubectl delete -f "${K8S_DIR}/deployment.yaml" --ignore-not-found

echo
echo "Deleting Redis Service..."
kubectl delete -f "${K8S_DIR}/redis-service.yaml" --ignore-not-found

echo
echo "Deleting Redis Deployment..."
kubectl delete -f "${K8S_DIR}/redis-deployment.yaml" --ignore-not-found

echo
echo "Deleting Redis PVC..."
kubectl delete -f "${K8S_DIR}/redis-pvc.yaml" --ignore-not-found

echo
echo "Deleting Redis Secret..."
kubectl delete -f "${K8S_DIR}/redis-secret.yaml" --ignore-not-found

echo
echo "Deleting Redis ConfigMap..."
kubectl delete -f "${K8S_DIR}/redis-configmap.yaml" --ignore-not-found

echo
echo "========================================"
echo " Application cleanup complete"
echo "========================================"
echo
echo "The kind cluster was NOT deleted."
echo