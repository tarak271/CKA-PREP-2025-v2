#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/course.sh"


DIR=$(ensure_course_dir 16)
rm -f "$DIR/resources.txt" "$DIR/crowded-namespace.txt"
for i in 1 2 3 4 5; do
  kubectl create namespace "project-$i" --dry-run=client -o yaml | kubectl apply -f -
  kubectl -n "project-$i" delete role --all --ignore-not-found 2>/dev/null || true
done
for r in $(seq 1 3); do kubectl -n project-1 create role "role-$r" --verb=get --resource=pods 2>/dev/null || true; done
for r in $(seq 1 5); do kubectl -n project-2 create role "role-$r" --verb=get --resource=pods 2>/dev/null || true; done
for r in $(seq 1 2); do kubectl -n project-3 create role "role-$r" --verb=get --resource=pods 2>/dev/null || true; done

