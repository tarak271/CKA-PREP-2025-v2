#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/course.sh"


DIR=$(ensure_course_dir 16)
rm -f "$DIR/resources.txt" "$DIR/crowded-namespace.txt"
for city in jinan miami melbourne seoul toronto; do
  kubectl create namespace "project-$city" --dry-run=client -o yaml | kubectl apply -f -
  kubectl -n "project-$city" delete role --all --ignore-not-found 2>/dev/null || true
done
for r in $(seq 1 300); do
  kubectl -n project-miami create role "role-$r" --verb=get --resource=pods 2>/dev/null || true
done
for r in $(seq 1 2); do kubectl -n project-melbourne create role "role-$r" --verb=get --resource=pods 2>/dev/null || true; done
for r in $(seq 1 10); do kubectl -n project-seoul create role "role-$r" --verb=get --resource=pods 2>/dev/null || true; done
echo "Ready: project-* namespaces with project-miami having most Roles"

