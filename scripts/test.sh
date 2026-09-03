#!/usr/bin/env bash

set -e

LOCAL_PORT="8080"
SERVICE_NAME="python-api"
SERVICE_PORT="80"
BASE_URL="http://localhost:${LOCAL_PORT}"

echo
echo "========================================"
echo " Redis Assignment - API Test"
echo "========================================"
echo

echo "Starting temporary port-forward..."

kubectl port-forward \
    "service/${SERVICE_NAME}" \
    "${LOCAL_PORT}:${SERVICE_PORT}" \
    >/tmp/redis-assignment-port-forward.log 2>&1 &

PORT_FORWARD_PID=$!

cleanup() {
    if kill -0 "${PORT_FORWARD_PID}" >/dev/null 2>&1; then
        kill "${PORT_FORWARD_PID}" >/dev/null 2>&1 || true
    fi
}

trap cleanup EXIT

sleep 2

if ! kill -0 "${PORT_FORWARD_PID}" >/dev/null 2>&1; then
    echo "ERROR: port-forward failed to start."
    cat /tmp/redis-assignment-port-forward.log
    exit 1
fi

echo "Port-forward is running."
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