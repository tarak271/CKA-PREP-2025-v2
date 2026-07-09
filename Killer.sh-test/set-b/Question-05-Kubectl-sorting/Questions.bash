#!/bin/bash
# Killer.sh Question 05: Kubectl sorting

cat <<'EOF'
Question 5 | Kubectl sorting

Solve this question on the local cluster.

Create two bash script files which use kubectl sorting to:

1. Write a command into /opt/course/5/find_pods.sh which lists all *Pods* in all *Namespaces* sorted by their AGE (metadata.creationTimestamp)  
2. Write a command into /opt/course/5/find_pods_uid.sh which lists all *Pods* in all *Namespaces* sorted by field metadata.uid

Course files are under /opt/course/5/
EOF
