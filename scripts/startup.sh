#!/usr/bin/env bash

set -e

CLUSTER_NAME="redis-cluster"
IMAGE_NAME="python-api:latest"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
K8S_DIR="${PROJECT_ROOT}/k8s"

echo
echo "========================================"
echo " Redis Assignment - Kubernetes Startup"
echo "========================================"
echo

echo "Project root:"
echo "${PROJECT_ROOT}"
echo

echo "Checking required commands..."

for command in docker kind kubectl; do
    if ! command -v "${command}" >/dev/null 2>&1; then
        echo "ERROR: ${command} is not installed or not available in PATH."
        exit 1
    fi

    echo "Found: ${command}"
done

echo
echo "Checking Docker..."

if ! docker info >/dev/null 2>&1; then
    echo "ERROR: Docker is not running."
    echo "Start Docker Desktop and run this script again."
    exit 1
fi

echo "Docker is running."

echo
echo "Checking kind cluster..."

if ! kind get clusters | grep -qx "${CLUSTER_NAME}"; then
    echo "ERROR: kind cluster '${CLUSTER_NAME}' does not exist."
    echo
    echo "Create it with:"
    echo "kind create cluster --name ${CLUSTER_NAME} --config ${K8S_DIR}/kind-cluster.yaml"
    exit 1
fi

echo "Cluster '${CLUSTER_NAME}' exists."

echo
echo "Switching kubectl context..."

kubectl config use-context "kind-${CLUSTER_NAME}" >/dev/null

echo "Current context:"
kubectl config current-context

echo
echo "Checking Kubernetes node..."

kubectl get nodes

echo
echo "Checking local FastAPI Docker image..."

if ! docker image inspect "${IMAGE_NAME}" >/dev/null 2>&1; then
    echo "ERROR: Docker image '${IMAGE_NAME}' does not exist."
    echo
    echo "Build it with:"
    echo "docker build -t ${IMAGE_NAME} ${PROJECT_ROOT}"
    exit 1
fi

echo "Found Docker image '${IMAGE_NAME}'."

echo
echo "Loading FastAPI image into kind..."

kind load docker-image "${IMAGE_NAME}" --name "${CLUSTER_NAME}"

echo
echo "Applying Redis ConfigMap..."

kubectl apply -f "${K8S_DIR}/redis-configmap.yaml"

echo
echo "Applying Redis Secret..."

kubectl apply -f "${K8S_DIR}/redis-secret.yaml"

echo
echo "Applying Redis PVC..."

kubectl apply -f "${K8S_DIR}/redis-pvc.yaml"

echo
echo "Applying Redis Deployment..."

kubectl apply -f "${K8S_DIR}/redis-deployment.yaml"

echo
echo "Applying Redis Service..."

kubectl apply -f "${K8S_DIR}/redis-service.yaml"

echo
echo "Waiting for Redis Deployment..."

kubectl rollout status deployment/redis --timeout=120s

echo
echo "Testing Redis..."

kubectl exec deployment/redis -- redis-cli ping

echo
echo "Applying FastAPI Deployment..."

kubectl apply -f "${K8S_DIR}/deployment.yaml"

echo
echo "Applying FastAPI NodePort Service..."

kubectl apply -f "${K8S_DIR}/service.yaml"

echo
echo "Waiting for FastAPI Deployment..."

kubectl rollout status deployment/python-api --timeout=120s

echo
echo "Current Kubernetes resources:"

kubectl get pods,services,deployments,pvc

echo
echo "========================================"
echo " Startup complete"
echo "========================================"
echo
echo "FastAPI:"
echo "  http://localhost:8080"
echo
echo "Swagger UI:"
echo "  http://localhost:8080/docs"
echo