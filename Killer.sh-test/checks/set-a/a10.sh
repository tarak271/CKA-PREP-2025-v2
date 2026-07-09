#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


kubectl -n project-hibiscus get rolebinding &>/dev/null && pass_task "rbac" "RBAC resources created in project-hibiscus" || fail_task "rbac" "RBAC resources created in project-hibiscus"


print_summary "a10"
