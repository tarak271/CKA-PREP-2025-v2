#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
reset_results

hpa_json=$(kubectl get hpa apache-server -n autoscale -o json 2>/dev/null || echo '{}')

# Task 1: Target deployment
target=$(echo "$hpa_json" | python3 -c "
import json,sys
d=json.load(sys.stdin)
ref=d.get('spec',{}).get('scaleTargetRef',{})
print(ref.get('kind',''), ref.get('name',''))
" 2>/dev/null || true)

if echo "$target" | grep -q 'Deployment apache-deployment'; then
  pass_task "hpa-target" "HPA apache-server targets deployment apache-deployment"
else
  fail_task "hpa-target" "HPA apache-server targets deployment apache-deployment" \
    "Create HPA named apache-server in autoscale namespace targeting apache-deployment"
fi

# Task 2: CPU 50%
cpu_util=$(echo "$hpa_json" | python3 -c "
import json,sys
d=json.load(sys.stdin)
for m in d.get('spec',{}).get('metrics',[]):
    if m.get('type')=='Resource' and m.get('resource',{}).get('name')=='cpu':
        print(m.get('resource',{}).get('target',{}).get('averageUtilization',''))
" 2>/dev/null || true)

if [[ "$cpu_util" == "50" ]]; then
  pass_task "cpu-target" "HPA targets 50% CPU utilization per pod"
else
  fail_task "cpu-target" "HPA targets 50% CPU utilization per pod" \
    "Set metrics resource cpu target averageUtilization to 50"
fi

# Task 3: Min/max replicas
min_rep=$(echo "$hpa_json" | python3 -c "import json,sys; print(json.load(sys.stdin).get('spec',{}).get('minReplicas',''))" 2>/dev/null)
max_rep=$(echo "$hpa_json" | python3 -c "import json,sys; print(json.load(sys.stdin).get('spec',{}).get('maxReplicas',''))" 2>/dev/null)

if [[ "$min_rep" == "1" && "$max_rep" == "4" ]]; then
  pass_task "replica-bounds" "HPA min replicas 1, max replicas 4"
else
  fail_task "replica-bounds" "HPA min replicas 1, max replicas 4" \
    "Current min=$min_rep max=$max_rep"
fi

# Task 4: Stabilization window
stab=$(echo "$hpa_json" | python3 -c "
import json,sys
d=json.load(sys.stdin)
print(d.get('spec',{}).get('behavior',{}).get('scaleDown',{}).get('stabilizationWindowSeconds',''))
" 2>/dev/null || true)

if [[ "$stab" == "30" ]]; then
  pass_task "stabilization" "Downscale stabilization window is 30 seconds"
else
  fail_task "stabilization" "Downscale stabilization window is 30 seconds" \
    "Set spec.behavior.scaleDown.stabilizationWindowSeconds: 30"
fi

print_summary "q05"
[[ $FAIL -eq 0 ]]
