#!/usr/bin/env bash

set -e

BASE_URL="http://localhost:8080"

echo
echo "========================================"
echo " Redis Assignment - API Test"
echo "========================================"
echo

echo "Testing FastAPI root endpoint..."

curl --fail --silent --show-error \
    "${BASE_URL}/"

echo
echo
echo "FastAPI root endpoint is reachable."
echo

read -r -p "Enter the key: " key
read -r -p "Enter the value: " value

echo
echo "Storing key/value in Redis through FastAPI..."

curl --fail --silent --show-error \
    -X POST \
    --get \
    --data-urlencode "key=${key}" \
    --data-urlencode "value=${value}" \
    "${BASE_URL}/cache"

echo
echo
echo "Retrieving key from Redis through FastAPI..."

curl --fail --silent --show-error \
    --get \
    --data-urlencode "key=${key}" \
    "${BASE_URL}/cache"

echo
echo
echo "========================================"
echo " API test complete"
echo "========================================"
echo