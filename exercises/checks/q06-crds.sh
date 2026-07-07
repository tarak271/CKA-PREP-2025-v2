#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
reset_results

# Task 1: CRD list file
if [[ -f /root/resources.yaml ]] && [[ -s /root/resources.yaml ]]; then
  if grep -qi 'cert-manager\|certificate\|issuer\|clusterissuer' /root/resources.yaml; then
    pass_task "crd-list" "cert-manager CRD list saved to /root/resources.yaml"
  else
    fail_task "crd-list" "cert-manager CRD list saved to /root/resources.yaml" \
      "File exists but does not list cert-manager CRDs"
  fi
else
  fail_task "crd-list" "cert-manager CRD list saved to /root/resources.yaml" \
    "Run: kubectl get crd | grep cert-manager > /root/resources.yaml"
fi

# Task 2: Subject documentation
if [[ -f /root/subject.yaml ]] && [[ -s /root/subject.yaml ]]; then
  if grep -qi 'subject\|FIELDS\|DESCRIPTION' /root/subject.yaml; then
    pass_task "subject-docs" "Certificate spec.subject docs saved to /root/subject.yaml"
  else
    fail_task "subject-docs" "Certificate spec.subject docs saved to /root/subject.yaml" \
      "File exists but does not contain subject field documentation"
  fi
else
  fail_task "subject-docs" "Certificate spec.subject docs saved to /root/subject.yaml" \
    "Run: kubectl explain certificate.spec.subject > /root/subject.yaml"
fi

print_summary "q06"
