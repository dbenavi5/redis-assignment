#!/usr/bin/env bash

set -e

CLUSTER_NAME="redis-cluster"

echo
echo "========================================"
echo " Redis Assignment - Kubernetes Status"
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
echo "Pods:"
kubectl get pods -o wide

echo
echo "Services:"
kubectl get services

echo
echo "Deployments:"
kubectl get deployments

echo
echo "PersistentVolumeClaims:"
kubectl get pvc

echo
echo "EndpointSlices:"
kubectl get endpointslices

echo
echo "========================================"
echo " Status check complete"
echo "========================================"
echo