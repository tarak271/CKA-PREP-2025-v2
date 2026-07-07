#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
reset_results

# Find tainted node (prefer node01, fallback to any node with PERMISSION taint)
tainted_node=""
for node in $(kubectl get nodes -o jsonpath='{.items[*].metadata.name}' 2>/dev/null); do
  if kubectl describe node "$node" 2>/dev/null | grep -q 'PERMISSION=granted:NoSchedule'; then
    tainted_node="$node"
    break
  fi
done

if [[ -z "$tainted_node" ]]; then
  if kubectl describe node node01 2>/dev/null | grep -q 'PERMISSION=granted:NoSchedule'; then
    tainted_node="node01"
  fi
fi

# Task 1: Node taint
if [[ -n "$tainted_node" ]]; then
  pass_task "node-taint" "Node tainted PERMISSION=granted:NoSchedule"
else
  fail_task "node-taint" "Node tainted PERMISSION=granted:NoSchedule" \
    "Run: kubectl taint nodes node01 PERMISSION=granted:NoSchedule"
fi

# Task 2: Pod with toleration on tainted node
found_pod=false
if [[ -n "$tainted_node" ]]; then
  while IFS= read -r pod_info; do
    [[ -z "$pod_info" ]] && continue
    pod_name=$(echo "$pod_info" | awk '{print $1}')
    pod_ns=$(echo "$pod_info" | awk '{print $2}')
    tolerates=$(kubectl get pod "$pod_name" -n "$pod_ns" -o json 2>/dev/null | python3 -c "
import json,sys
d=json.load(sys.stdin)
for t in d.get('spec',{}).get('tolerations',[]):
    if t.get('key')=='PERMISSION' and t.get('value')=='granted' and t.get('effect')=='NoSchedule':
        print('yes')
        break
" 2>/dev/null || true)
    node=$(kubectl get pod "$pod_name" -n "$pod_ns" -o jsonpath='{.spec.nodeName}' 2>/dev/null)
    phase=$(kubectl get pod "$pod_name" -n "$pod_ns" -o jsonpath='{.status.phase}' 2>/dev/null)
    if [[ "$tolerates" == "yes" && "$node" == "$tainted_node" && "$phase" == "Running" ]]; then
      found_pod=true
      break
    fi
  done < <(kubectl get pods -A --field-selector=status.phase=Running -o custom-columns=NAME:.metadata.name,NS:.metadata.namespace,NODE:.spec.nodeName --no-headers 2>/dev/null | \
    awk -v n="$tainted_node" '$3==n {print $1, $2}')
fi

if $found_pod; then
  pass_task "tolerating-pod" "Pod with correct toleration scheduled on tainted node"
else
  fail_task "tolerating-pod" "Pod with correct toleration scheduled on tainted node" \
    "Create a pod with toleration key=PERMISSION, value=granted, effect=NoSchedule"
fi

print_summary "q10"
