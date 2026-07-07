#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
reset_results

gw_json=$(kubectl get gateway web-gateway -o json 2>/dev/null || echo '{}')
hr_json=$(kubectl get httproute web-route -o json 2>/dev/null || echo '{}')

# Task 1: Gateway
gw_ok=$(echo "$gw_json" | python3 -c "
import json,sys
d=json.load(sys.stdin)
if d.get('kind')!='Gateway':
    sys.exit(1)
spec=d.get('spec',{})
if spec.get('gatewayClassName')!='nginx-class':
    sys.exit(1)
listeners=spec.get('listeners',[])
for l in listeners:
    if l.get('hostname')=='gateway.web.k8s.local':
        if l.get('protocol') in ('HTTPS','TLS'):
            tls=l.get('tls',{})
            if tls.get('mode')=='Terminate' or tls.get('certificateRefs'):
                print('ok')
                sys.exit(0)
sys.exit(1)
" 2>/dev/null || true)

if [[ "$gw_ok" == "ok" ]]; then
  pass_task "gateway" "Gateway web-gateway with hostname gateway.web.k8s.local and TLS"
else
  fail_task "gateway" "Gateway web-gateway with hostname gateway.web.k8s.local and TLS" \
    "Create Gateway web-gateway with gatewayClassName nginx-class, HTTPS listener, TLS from web-tls secret"
fi

# Task 2: HTTPRoute
hr_ok=$(echo "$hr_json" | python3 -c "
import json,sys
d=json.load(sys.stdin)
if d.get('kind')!='HTTPRoute':
    sys.exit(1)
spec=d.get('spec',{})
hostnames=spec.get('hostnames',[])
if 'gateway.web.k8s.local' not in hostnames:
    sys.exit(1)
for rule in spec.get('rules',[]):
    for ref in rule.get('backendRefs',[]):
        if ref.get('name')=='web-service' and ref.get('port')==80:
            print('ok')
            sys.exit(0)
sys.exit(1)
" 2>/dev/null || true)

if [[ "$hr_ok" == "ok" ]]; then
  pass_task "httproute" "HTTPRoute web-route with routing to web-service"
else
  fail_task "httproute" "HTTPRoute web-route with routing to web-service" \
    "Create HTTPRoute web-route referencing web-gateway and backend web-service:80"
fi

print_summary "q11"
