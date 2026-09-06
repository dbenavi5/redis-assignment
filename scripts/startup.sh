#!/usr/bin/env bash

set -e

CLUSTER_NAME="redis-cluster"
IMAGE_NAME="python-api:latest"
RELEASE_NAME="redis-assignment"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
K8S_DIR="${PROJECT_ROOT}/k8s"
HELM_CHART="${PROJECT_ROOT}/helm/redis-assignment"

echo
echo "========================================"
echo " Redis Assignment - Helm Startup"
echo "========================================"
echo

echo "Project root:"
echo "${PROJECT_ROOT}"
echo

echo "Checking required commands..."

for command in docker kind kubectl helm; do
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
echo "Checking NGINX Ingress Controller..."

if ! kubectl get namespace ingress-nginx >/dev/null 2>&1; then
    echo "ERROR: ingress-nginx is not installed."
    echo "Install ingress-nginx before running this script."
    exit 1
fi

if ! kubectl get deployment \
    ingress-nginx-controller \
    -n ingress-nginx >/dev/null 2>&1; then

    echo "ERROR: ingress-nginx controller Deployment was not found."
    exit 1
fi

echo "NGINX Ingress Controller is installed."

echo
echo "Waiting for NGINX Ingress Controller..."

kubectl rollout status \
    deployment/ingress-nginx-controller \
    -n ingress-nginx \
    --timeout=120s

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

kind load docker-image "${IMAGE_NAME}" \
    --name "${CLUSTER_NAME}"

echo
echo "Linting Helm chart..."

helm lint "${HELM_CHART}"

echo
echo "Deploying application with Helm..."

helm upgrade \
    --install \
    "${RELEASE_NAME}" \
    "${HELM_CHART}" \
    --wait \
    --timeout 2m

echo
echo "Helm release:"
helm list

echo
echo "Current Kubernetes resources:"
kubectl get pods,services,deployments,pvc,ingress

echo
echo "========================================"
echo " Startup complete"
echo "========================================"
echo
echo "FastAPI:"
echo "  http://localhost/api"
echo
echo "Swagger UI:"
echo "  http://localhost/api/docs"
echo