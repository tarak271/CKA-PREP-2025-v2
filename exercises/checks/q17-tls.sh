#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
reset_results

# Task 1: ConfigMap TLSv1.3 only
cm_data=$(kubectl get configmap nginx-config -n nginx-static -o jsonpath='{.data.nginx\.conf}' 2>/dev/null || true)
if echo "$cm_data" | grep -q 'TLSv1.3' && ! echo "$cm_data" | grep -q 'TLSv1.2'; then
  pass_task "tls-config" "ConfigMap configured to support only TLSv1.3"
else
  fail_task "tls-config" "ConfigMap configured to support only TLSv1.3" \
    "Edit nginx-config ConfigMap — remove TLSv1.2 from ssl_protocols, restart deployment"
fi

# Task 2: /etc/hosts entry
if grep -q 'ckaquestion.k8s.local' /etc/hosts 2>/dev/null; then
  pass_task "hosts-entry" "/etc/hosts entry for ckaquestion.k8s.local"
else
  fail_task "hosts-entry" "/etc/hosts entry for ckaquestion.k8s.local" \
    "Add service ClusterIP: echo \"<IP> ckaquestion.k8s.local\" | sudo tee -a /etc/hosts"
fi

# Task 3: TLS verification via curl
tls12_fails=false
tls13_works=false

if command -v curl &>/dev/null && grep -q 'ckaquestion.k8s.local' /etc/hosts 2>/dev/null; then
  if ! curl -vk --tls-max 1.2 --connect-timeout 5 https://ckaquestion.k8s.local 2>&1 | grep -qi 'SSL\|TLS\|error\|refused\|handshake'; then
    # TLS 1.2 should fail - if curl exits non-zero or handshake fails, that's good
    :
  fi
  if ! curl -sk --tls-max 1.2 --connect-timeout 5 https://ckaquestion.k8s.local &>/dev/null; then
    tls12_fails=true
  fi
  if curl -sk --tlsv1.3 --connect-timeout 5 https://ckaquestion.k8s.local &>/dev/null; then
    tls13_works=true
  fi
fi

if $tls12_fails && $tls13_works; then
  pass_task "tls-verification" "TLSv1.2 rejected and TLSv1.3 accepted"
elif ! grep -q 'ckaquestion.k8s.local' /etc/hosts 2>/dev/null; then
  fail_task "tls-verification" "TLSv1.2 rejected and TLSv1.3 accepted" \
    "Fix /etc/hosts first, then restart nginx deployment"
else
  fail_task "tls-verification" "TLSv1.2 rejected and TLSv1.3 accepted" \
    "TLSv1.2 should fail: curl -vk --tls-max 1.2 https://ckaquestion.k8s.local | TLSv1.3 should work"
fi

print_summary "q17"
[[ $FAIL -eq 0 ]]
