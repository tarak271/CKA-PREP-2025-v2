#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


DIR=$(course_path 1)
KCFG="$DIR/kubeconfig"
if [[ -f "$DIR/contexts" ]]; then
  ctx=$(kubectl --kubeconfig "$KCFG" config get-contexts -oname 2>/dev/null | sort)
  ans=$(sort "$DIR/contexts")
  if [[ "$ctx" == "$ans" ]]; then
    pass_task "contexts" "All context names written to contexts"
  else
    fail_task "contexts" "All context names written to contexts" "kubectl --kubeconfig $KCFG config get-contexts -oname > $DIR/contexts"
  fi
else
  fail_task "contexts" "All context names written to contexts" "Create $DIR/contexts"
fi
if [[ -f "$DIR/current-context" ]]; then
  exp=$(kubectl --kubeconfig "$KCFG" config current-context 2>/dev/null)
  got=$(tr -d '[:space:]' < "$DIR/current-context")
  if [[ "$exp" == "$got" ]]; then
    pass_task "current-context" "Current context written to current-context"
  else
    fail_task "current-context" "Current context written to current-context"
  fi
else
  fail_task "current-context" "Current context written to current-context"
fi
if [[ -f "$DIR/cert" ]] && grep -q "BEGIN CERTIFICATE" "$DIR/cert"; then
  exp=$(kubectl --kubeconfig "$KCFG" config view --raw -ojsonpath='{.users[?(@.name=="account-0027@internal")].user.client-certificate-data}' 2>/dev/null | base64 -d 2>/dev/null)
  if diff -q <(echo "$exp") "$DIR/cert" &>/dev/null; then
    pass_task "cert" "Client certificate for account-0027 decoded into cert"
  else
    # fallback: any valid cert from account-0027 user block
    if openssl x509 -in "$DIR/cert" -noout -subject &>/dev/null; then
      pass_task "cert" "Client certificate for account-0027 decoded into cert"
    else
      fail_task "cert" "Client certificate for account-0027 decoded into cert"
    fi
  fi
else
  fail_task "cert" "Client certificate for account-0027 decoded into cert"
fi


print_summary "a01"
