#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
reset_results

deploy_json=$(kubectl get deployment nodeport-deployment -n relative -o json 2>/dev/null || echo '{}')

# Task 1: Container port 80 name=http
port_ok=$(echo "$deploy_json" | python3 -c "
import json,sys
d=json.load(sys.stdin)
for c in d.get('spec',{}).get('template',{}).get('spec',{}).get('containers',[]):
    for p in c.get('ports',[]):
        if p.get('containerPort')==80 and p.get('name')=='http' and p.get('protocol','TCP')=='TCP':
            print('ok')
            sys.exit(0)
sys.exit(1)
" 2>/dev/null || true)

if [[ "$port_ok" == "ok" ]]; then
  pass_task "container-port" "Deployment exposes container port 80 (name=http, TCP)"
else
  fail_task "container-port" "Deployment exposes container port 80 (name=http, TCP)" \
    "Patch deployment to add ports: [{name: http, containerPort: 80, protocol: TCP}]"
fi

# Task 2: NodePort service on 30080
if kubectl get svc nodeport-service -n relative &>/dev/null; then
  node_port=$(kubectl get svc nodeport-service -n relative -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)
  if [[ "$node_port" == "30080" ]]; then
    pass_task "nodeport-service" "Service nodeport-service created with NodePort 30080"
  else
    fail_task "nodeport-service" "Service nodeport-service created with NodePort 30080" \
      "Current nodePort: $node_port"
  fi
else
  fail_task "nodeport-service" "Service nodeport-service created with NodePort 30080" \
    "Create Service nodeport-service with nodePort 30080"
fi

# Task 3: Service type NodePort port 80
if kubectl get svc nodeport-service -n relative &>/dev/null; then
  svc_type=$(kubectl get svc nodeport-service -n relative -o jsonpath='{.spec.type}' 2>/dev/null)
  port=$(kubectl get svc nodeport-service -n relative -o jsonpath='{.spec.ports[0].port}' 2>/dev/null)
  if [[ "$svc_type" == "NodePort" && "$port" == "80" ]]; then
    pass_task "service-type" "Service type is NodePort exposing port 80"
  else
    fail_task "service-type" "Service type is NodePort exposing port 80" \
      "type=$svc_type port=$port"
  fi
else
  fail_task "service-type" "Service type is NodePort exposing port 80"
fi

print_summary "q16"
