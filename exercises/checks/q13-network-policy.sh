#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
reset_results

# Task 1: Network policy deployed
if kubectl get networkpolicy -n backend --no-headers 2>/dev/null | grep -q .; then
  pass_task "policy-deployed" "Network policy deployed in backend namespace"
else
  fail_task "policy-deployed" "Network policy deployed in backend namespace" \
    "Apply one of the policies from /root/network-policies/"
fi

# Task 2: Correct policy (policy-z / network-policy-3.yaml)
correct=false
for np in $(kubectl get networkpolicy -n backend -o jsonpath='{.items[*].metadata.name}' 2>/dev/null); do
  np_json=$(kubectl get networkpolicy "$np" -n backend -o json 2>/dev/null)
  is_correct=$(echo "$np_json" | python3 -c "
import json,sys
d=json.load(sys.stdin)
spec=d.get('spec',{})
ingress=spec.get('ingress',[])
if not ingress:
    sys.exit(1)
for rule in ingress:
    from_rules=rule.get('from',[])
    has_ns=False
    has_pod=False
    has_ip=False
    for f in from_rules:
        if f.get('namespaceSelector'):
            has_ns=True
        if f.get('podSelector'):
            has_pod=True
        if f.get('ipBlock'):
            has_ip=True
    if has_ns and has_pod and not has_ip:
        print('ok')
        sys.exit(0)
sys.exit(1)
" 2>/dev/null || true)
  if [[ "$is_correct" == "ok" ]]; then
    correct=true
    break
  fi
done

if $correct; then
  pass_task "least-permissive" "Correct least-permissive policy (policy-z) applied"
else
  fail_task "least-permissive" "Correct least-permissive policy (policy-z) applied" \
    "Deploy network-policy-3.yaml — allows only frontend namespace and app=frontend pods"
fi

print_summary "q13"
[[ $FAIL -eq 0 ]]
