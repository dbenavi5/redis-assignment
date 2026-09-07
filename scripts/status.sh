#!/usr/bin/env bash

set -e

ARGO_APP_NAME="redis-assignment"

echo
echo "========================================"
echo " Redis Assignment - Istio GitOps Status"
echo "========================================"
echo

echo "Current kubectl context:"
kubectl config current-context

echo
echo "Kind clusters:"
kind get clusters

echo
echo "Kubernetes nodes:"
kubectl get nodes

echo
echo "Argo CD Application:"
argocd app get "${ARGO_APP_NAME}" || true

echo
echo "Application Pods:"
kubectl get pods -o wide

echo
echo "Application Services:"
kubectl get services

echo
echo "Application Deployments:"
kubectl get deployments

echo
echo "PersistentVolumeClaims:"
kubectl get pvc

echo
echo "NGINX Ingress resources:"
kubectl get ingress

echo
echo "NGINX Ingress Controller:"
kubectl get pods -n ingress-nginx

echo
echo "Argo CD Pods:"
kubectl get pods -n argocd

echo
echo "Istio Control Plane:"
kubectl get pods -n istio-system

echo
echo "Istio Gateways:"
kubectl get gateway.networking.istio.io || true

echo
echo "Istio VirtualServices:"
kubectl get virtualservice || true

echo
echo "Istio PeerAuthentication policies:"
kubectl get peerauthentication || true

echo
echo "Istio proxy status:"
istioctl proxy-status || true

echo
echo "EndpointSlices:"
kubectl get endpointslices

echo
echo "========================================"
echo " Status check complete"
echo "========================================"
echo