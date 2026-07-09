#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


cm=$(kubectl -n lima-control get cm control-config -o yaml 2>/dev/null)
echo "$cm" | grep -q 'kubernetes.default.svc.cluster.local' && pass_task "dns1" "DNS_1 correct" || fail_task "dns1" "DNS_1 correct"
echo "$cm" | grep -q 'department.lima-workload.svc.cluster.local' && pass_task "dns2" "DNS_2 correct" || fail_task "dns2" "DNS_2 correct"
echo "$cm" | grep -q 'section100.section.lima-workload.svc.cluster.local' && pass_task "dns3" "DNS_3 correct" || fail_task "dns3" "DNS_3 correct"
echo "$cm" | grep -q '1-2-3-4.kube-system.pod.cluster.local' && pass_task "dns4" "DNS_4 correct" || fail_task "dns4" "DNS_4 correct"


print_summary "b01"
