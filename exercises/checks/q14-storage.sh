#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
reset_results

# Task 1: StorageClass local-storage
if kubectl get storageclass local-storage &>/dev/null; then
  provisioner=$(kubectl get storageclass local-storage -o jsonpath='{.provisioner}' 2>/dev/null)
  binding=$(kubectl get storageclass local-storage -o jsonpath='{.volumeBindingMode}' 2>/dev/null)
  if [[ "$provisioner" == "rancher.io/local-path" ]] && [[ "$binding" == "WaitForFirstConsumer" ]]; then
    pass_task "storage-class" "StorageClass local-storage with rancher.io/local-path provisioner"
  else
    fail_task "storage-class" "StorageClass local-storage with rancher.io/local-path provisioner" \
      "provisioner=$provisioner binding=$binding"
  fi
else
  fail_task "storage-class" "StorageClass local-storage with rancher.io/local-path provisioner" \
    "Create StorageClass local-storage with provisioner rancher.io/local-path"
fi

# Task 2: local-storage is default
if kubectl get storageclass local-storage &>/dev/null; then
  is_default=$(kubectl get storageclass local-storage -o jsonpath='{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}' 2>/dev/null)
  if [[ "$is_default" == "true" ]]; then
    pass_task "default-patched" "local-storage patched to be default StorageClass"
  else
    fail_task "default-patched" "local-storage patched to be default StorageClass" \
      "Patch annotation storageclass.kubernetes.io/is-default-class: \"true\""
  fi
else
  fail_task "default-patched" "local-storage patched to be default StorageClass"
fi

# Task 3: Only one default
default_count=$(kubectl get storageclass -o json 2>/dev/null | python3 -c "
import json,sys
d=json.load(sys.stdin)
count=0
for sc in d.get('items',[]):
    ann=sc.get('metadata',{}).get('annotations',{})
    if ann.get('storageclass.kubernetes.io/is-default-class')=='true':
        count+=1
print(count)
" 2>/dev/null || echo 0)

if [[ "$default_count" == "1" ]]; then
  only_default=$(kubectl get storageclass -o json 2>/dev/null | python3 -c "
import json,sys
d=json.load(sys.stdin)
for sc in d.get('items',[]):
    ann=sc.get('metadata',{}).get('annotations',{})
    if ann.get('storageclass.kubernetes.io/is-default-class')=='true':
        print(sc.get('metadata',{}).get('name',''))
" 2>/dev/null)
  if [[ "$only_default" == "local-storage" ]]; then
    pass_task "only-default" "local-storage is the only default StorageClass"
  else
    fail_task "only-default" "local-storage is the only default StorageClass" \
      "Default class is $only_default, expected local-storage"
  fi
else
  fail_task "only-default" "local-storage is the only default StorageClass" \
    "Found $default_count default StorageClasses (expected exactly 1)"
fi

print_summary "q14"
[[ $FAIL -eq 0 ]]
