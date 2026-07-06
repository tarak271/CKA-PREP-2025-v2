#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
reset_results

# Task 1: NodePort service
if kubectl get svc echo-service -n echo-sound &>/dev/null; then
  svc_type=$(kubectl get svc echo-service -n echo-sound -o jsonpath='{.spec.type}' 2>/dev/null)
  port=$(kubectl get svc echo-service -n echo-sound -o jsonpath='{.spec.ports[0].port}' 2>/dev/null)
  if [[ "$svc_type" == "NodePort" && "$port" == "8080" ]]; then
    pass_task "nodeport-service" "Service echo-service exposed as NodePort on port 8080"
  else
    fail_task "nodeport-service" "Service echo-service exposed as NodePort on port 8080" \
      "Current type=$svc_type port=$port"
  fi
else
  fail_task "nodeport-service" "Service echo-service exposed as NodePort on port 8080" \
    "Run: kubectl expose deployment echo -n echo-sound --name echo-service --type NodePort --port 8080"
fi

# Task 2: Ingress
if kubectl get ingress echo -n echo-sound &>/dev/null; then
  host=$(kubectl get ingress echo -n echo-sound -o jsonpath='{.spec.rules[0].host}' 2>/dev/null)
  path=$(kubectl get ingress echo -n echo-sound -o jsonpath='{.spec.rules[0].http.paths[0].path}' 2>/dev/null)
  backend=$(kubectl get ingress echo -n echo-sound -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}' 2>/dev/null)
  if [[ "$host" == "example.org" && "$path" == "/echo" && "$backend" == "echo-service" ]]; then
    pass_task "ingress" "Ingress echo routes example.org/echo to echo-service"
  else
    fail_task "ingress" "Ingress echo routes example.org/echo to echo-service" \
      "Current host=$host path=$path backend=$backend"
  fi
else
  fail_task "ingress" "Ingress echo routes example.org/echo to echo-service" \
    "Create Ingress named echo in echo-sound namespace"
fi

print_summary "q12"
[[ $FAIL -eq 0 ]]
