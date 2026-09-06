#!/usr/bin/env bash

set -e

echo
echo "========================================"
echo " Redis Assignment - Helm Status"
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
echo "Helm releases:"
helm list

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
echo "Ingress resources:"
kubectl get ingress

echo
echo "NGINX Ingress Controller:"
kubectl get pods -n ingress-nginx

echo
echo "EndpointSlices:"
kubectl get endpointslices

echo
echo "========================================"
echo " Status check complete"
echo "========================================"
echo