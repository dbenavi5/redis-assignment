#!/usr/bin/env bash

set -e

CLUSTER_NAME="redis-cluster"
IMAGE_NAME="python-api:latest"
ARGO_APP_NAME="redis-assignment"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
K8S_DIR="${PROJECT_ROOT}/k8s"
ARGOCD_APP="${PROJECT_ROOT}/argocd/application.yaml"

echo
echo "========================================"
echo " Redis Assignment - Argo CD Startup"
echo "========================================"
echo

echo "Project root:"
echo "${PROJECT_ROOT}"
echo

echo "Checking required commands..."

for command in docker kind kubectl argocd; do
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
    exit 1
fi

kubectl rollout status \
    deployment/ingress-nginx-controller \
    -n ingress-nginx \
    --timeout=120s

echo
echo "Checking Argo CD..."

if ! kubectl get namespace argocd >/dev/null 2>&1; then
    echo "ERROR: Argo CD is not installed."
    echo
    echo "Install Argo CD before running this script."
    exit 1
fi

kubectl rollout status \
    deployment/argocd-server \
    -n argocd \
    --timeout=180s

kubectl rollout status \
    deployment/argocd-repo-server \
    -n argocd \
    --timeout=180s

echo
echo "Checking local FastAPI image..."

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

kind load docker-image \
    "${IMAGE_NAME}" \
    --name "${CLUSTER_NAME}"

echo
echo "Applying Argo CD Application..."

kubectl apply -f "${ARGOCD_APP}"

echo
echo "Refreshing Argo CD Application..."

argocd app get "${ARGO_APP_NAME}" --refresh >/dev/null 2>&1 || true

echo
echo "Argo CD Application:"
argocd app get "${ARGO_APP_NAME}" || true

echo
echo "Current Kubernetes resources:"
kubectl get pods,services,deployments,pvc,ingress

echo
echo "========================================"
echo " GitOps bootstrap complete"
echo "========================================"
echo
echo "Application:"
echo "  http://localhost/api"
echo
echo "Swagger:"
echo "  http://localhost/api/docs"
echo
echo "Normal deployments should now happen"
echo "through Git commit + git push."
echo
