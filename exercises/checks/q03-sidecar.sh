#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
reset_results

deploy_json=$(kubectl get deployment wordpress -o json 2>/dev/null || echo '{}')

# Task 1: Sidecar container
sidecar_image=$(echo "$deploy_json" | python3 -c "
import json,sys
d=json.load(sys.stdin)
for c in d.get('spec',{}).get('template',{}).get('spec',{}).get('containers',[]):
    if c.get('name')=='sidecar':
        print(c.get('image',''))
        break
" 2>/dev/null || true)

if [[ "$sidecar_image" == *"busybox"* ]]; then
  pass_task "sidecar-container" "Sidecar container named sidecar using busybox:stable image"
else
  fail_task "sidecar-container" "Sidecar container named sidecar using busybox:stable image" \
    "Add container named sidecar with image busybox:stable"
fi

# Task 2: Sidecar command
sidecar_cmd=$(echo "$deploy_json" | python3 -c "
import json,sys
d=json.load(sys.stdin)
for c in d.get('spec',{}).get('template',{}).get('spec',{}).get('containers',[]):
    if c.get('name')=='sidecar':
        cmd=c.get('command',[])
        args=c.get('args',[])
        print(' '.join(cmd+args))
        break
" 2>/dev/null || true)

if echo "$sidecar_cmd" | grep -q 'tail' && echo "$sidecar_cmd" | grep -q 'wordpress.log'; then
  pass_task "sidecar-command" "Sidecar runs tail -f /var/log/wordpress.log"
else
  fail_task "sidecar-command" "Sidecar runs tail -f /var/log/wordpress.log" \
    'Use command: ["/bin/sh","-c","tail -f /var/log/wordpress.log"]'
fi

# Task 3: Shared volume
volume_check=$(echo "$deploy_json" | python3 -c "
import json,sys
d=json.load(sys.stdin)
spec=d.get('spec',{}).get('template',{}).get('spec',{})
volumes=spec.get('volumes',[])
containers=spec.get('containers',[])
if not volumes:
    sys.exit(1)
log_mounts=[]
for c in containers:
    for m in c.get('volumeMounts',[]):
        if m.get('mountPath')=='/var/log':
            log_mounts.append(c.get('name'))
if len(log_mounts)>=2:
    print('ok')
else:
    sys.exit(1)
" 2>/dev/null || true)

if [[ "$volume_check" == "ok" ]]; then
  pass_task "shared-volume" "Shared volume mounted at /var/log in both containers"
else
  fail_task "shared-volume" "Shared volume mounted at /var/log in both containers" \
    "Add a shared volume and mount it at /var/log in wordpress and sidecar containers"
fi

print_summary "q03"
