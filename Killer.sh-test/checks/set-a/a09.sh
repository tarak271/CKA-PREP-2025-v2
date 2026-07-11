#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


kubectl -n project-swan get serviceaccount secret-reader &>/dev/null &&           pass_task "sa" "ServiceAccount secret-reader exists" ||           fail_task "sa" "ServiceAccount secret-reader exists"
sa=$(kubectl -n project-swan get pod api-contact -o jsonpath='{.spec.serviceAccountName}' 2>/dev/null || echo "")
[[ "$sa" == "secret-reader" ]] && pass_task "pod-sa" "Pod api-contact uses secret-reader" ||           fail_task "pod-sa" "Pod api-contact uses secret-reader" "Set serviceAccountName: secret-reader on pod api-contact"
FILE="$(course_path 9)/result.json"
if [[ -f "$FILE" ]] && python3 -c "
import json, sys
d=json.load(open('$FILE'))
assert d.get('kind')=='SecretList', 'expected SecretList'
assert 'items' in d, 'missing items'
" 2>/dev/null; then
  pass_task "json" "result.json contains SecretList from API call"
else
  fail_task "json" "result.json contains SecretList from API call"             "curl -k https://kubernetes.default/api/v1/secrets -H "Authorization: Bearer \$TOKEN" and save to $FILE"
fi


print_summary "a09"
