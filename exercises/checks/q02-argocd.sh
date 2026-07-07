#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
reset_results

# Task 1: Helm repo
if helm repo list 2>/dev/null | awk '{print $1}' | grep -qx 'argocd'; then
  pass_task "helm-repo" "Argo CD Helm repository added with name argocd"
else
  fail_task "helm-repo" "Argo CD Helm repository added with name argocd" \
    "Run: helm repo add argocd https://argoproj.github.io/argo-helm"
fi

# Task 2: Namespace
if kubectl get namespace argocd &>/dev/null; then
  pass_task "namespace" "Namespace argocd exists"
else
  fail_task "namespace" "Namespace argocd exists" \
    "Run: kubectl create namespace argocd"
fi

# Task 3: Manifest file
if [[ -f /root/argo-helm.yaml ]] && [[ -s /root/argo-helm.yaml ]]; then
  pass_task "manifest-file" "Generated manifest saved to /root/argo-helm.yaml"
else
  fail_task "manifest-file" "Generated manifest saved to /root/argo-helm.yaml" \
    "Run: helm template ... > /root/argo-helm.yaml"
fi

# Task 4: Chart version
if [[ -f /root/argo-helm.yaml ]]; then
  if grep -q '7\.7\.3' /root/argo-helm.yaml || \
     helm template argocd argo/argo-cd --version 7.7.3 --set crds.install=false --namespace argocd 2>/dev/null | \
       diff -q - /root/argo-helm.yaml &>/dev/null; then
    pass_task "chart-version" "Manifest generated from Argo CD chart version 7.7.3"
  else
    fail_task "chart-version" "Manifest generated from Argo CD chart version 7.7.3" \
      "Use: helm template argocd argo/argo-cd --version 7.7.3 ..."
  fi
else
  fail_task "chart-version" "Manifest generated from Argo CD chart version 7.7.3"
fi

# Task 5: CRDs disabled
if [[ -f /root/argo-helm.yaml ]]; then
  if ! grep -q 'kind: CustomResourceDefinition' /root/argo-helm.yaml; then
    pass_task "crds-disabled" "CRDs are not installed (crds.install=false)"
  else
    fail_task "crds-disabled" "CRDs are not installed (crds.install=false)" \
      "Use --set crds.install=false when generating the template"
  fi
else
  fail_task "crds-disabled" "CRDs are not installed (crds.install=false)"
fi

print_summary "q02"
