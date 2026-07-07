#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
reset_results

deploy_json=$(kubectl get deployment wordpress -o json 2>/dev/null || echo '{}')

# Task 1: 3 replicas
replicas=$(echo "$deploy_json" | python3 -c "import json,sys; print(json.load(sys.stdin).get('spec',{}).get('replicas',0))" 2>/dev/null || echo 0)
if [[ "$replicas" == "3" ]]; then
  pass_task "replica-count" "WordPress deployment scaled to 3 replicas"
else
  fail_task "replica-count" "WordPress deployment scaled to 3 replicas" \
    "Current replicas: $replicas. Run: kubectl scale deployment wordpress --replicas 3"
fi

# Collect resource values from all containers (init + main)
resource_check=$(echo "$deploy_json" | python3 -c "
import json,sys
d=json.load(sys.stdin)
spec=d.get('spec',{}).get('template',{}).get('spec',{})
containers=spec.get('containers',[])
inits=spec.get('initContainers',[])
all_c=inits+containers
if not all_c:
    print('no-containers')
    sys.exit(0)
cpu_req=set()
cpu_lim=set()
mem_req=set()
mem_lim=set()
for c in all_c:
    r=c.get('resources',{})
    req=r.get('requests',{})
    lim=r.get('limits',{})
    if not req.get('cpu') or not req.get('memory') or not lim.get('cpu') or not lim.get('memory'):
        print('missing-resources')
        sys.exit(0)
    cpu_req.add(req['cpu'])
    cpu_lim.add(lim['cpu'])
    mem_req.add(req['memory'])
    mem_lim.add(lim['memory'])
print(f'{len(cpu_req)}|{len(cpu_lim)}|{len(mem_req)}|{len(mem_lim)}|{len(inits)}|{len(containers)}')
" 2>/dev/null || echo "error")

IFS='|' read -r cpu_req_count cpu_lim_count mem_req_count mem_lim_count init_count main_count <<< "$resource_check"

if [[ "$resource_check" == "missing-resources" ]]; then
  fail_task "equal-cpu" "All containers have equal CPU requests and limits" "Set resources on all init and main containers"
  fail_task "equal-memory" "All containers have equal memory requests and limits" "Set resources on all init and main containers"
  fail_task "init-main-match" "Init containers use the same resources as main containers"
elif [[ "$cpu_req_count" == "1" && "$cpu_lim_count" == "1" ]]; then
  pass_task "equal-cpu" "All containers have equal CPU requests and limits"
else
  fail_task "equal-cpu" "All containers have equal CPU requests and limits" \
    "Ensure every container has the same cpu requests and limits"
fi

if [[ "$resource_check" != "missing-resources" && "$resource_check" != "error" ]]; then
  if [[ "$mem_req_count" == "1" && "$mem_lim_count" == "1" ]]; then
    pass_task "equal-memory" "All containers have equal memory requests and limits"
  else
    fail_task "equal-memory" "All containers have equal memory requests and limits"
  fi

  if [[ "$init_count" -gt 0 && "$main_count" -gt 0 && "$cpu_req_count" == "1" ]]; then
    pass_task "init-main-match" "Init containers use the same resources as main containers"
  elif [[ "$init_count" -eq 0 ]]; then
    fail_task "init-main-match" "Init containers use the same resources as main containers" \
      "Deployment should have init containers with matching resources"
  else
    fail_task "init-main-match" "Init containers use the same resources as main containers"
  fi
fi

# Task 5: Pods running
running=$(kubectl get pods -l app=wordpress --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l | tr -d ' ')
if [[ "$running" == "3" ]]; then
  pass_task "pods-running" "All WordPress pods are running"
else
  fail_task "pods-running" "All WordPress pods are running" \
    "Expected 3 running pods, found $running. Check: kubectl get pods -l app=wordpress"
fi

print_summary "q04"
