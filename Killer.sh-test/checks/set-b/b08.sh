#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


FILE="$(course_path 8)/controlplane-components.txt"
[[ -f "$FILE" ]] && grep -qi kube-apiserver "$FILE" && pass_task "components" "Control plane components documented" || fail_task "components" "Control plane components documented"


print_summary "b08"
