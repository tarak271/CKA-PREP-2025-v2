#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


[[ -f "$(course_path 16)/coredns_backup.yaml" ]] && pass_task "backup" "CoreDNS backup saved" || fail_task "backup" "CoreDNS backup saved"
fwd=$(kubectl -n kube-system get cm coredns -o yaml 2>/dev/null | grep -c forward || echo 0)
[[ "$fwd" -ge 1 ]] && pass_task "forward" "CoreDNS forward plugin configured" || fail_task "forward" "CoreDNS forward plugin configured"


print_summary "a16"
