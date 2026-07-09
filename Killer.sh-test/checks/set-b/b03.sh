#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


FILE="$(course_path 3)/certificate-info.txt"
if [[ -f "$FILE" ]]; then
  grep -qi "client authentication" "$FILE" && pass_task "client-cert" "Kubelet client cert info present" || fail_task "client-cert" "Kubelet client cert info present"
  grep -qi "server authentication" "$FILE" && pass_task "server-cert" "Kubelet server cert info present" || fail_task "server-cert" "Kubelet server cert info present"
else
  fail_task "client-cert" "certificate-info.txt created"
  fail_task "server-cert" "certificate-info.txt created"
fi


print_summary "b03"
