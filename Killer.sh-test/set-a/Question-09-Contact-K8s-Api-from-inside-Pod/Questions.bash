#!/bin/bash
# Killer.sh Question 09: Contact K8s Api from inside Pod

cat <<'EOF'
Question 9 | Contact K8s Api from inside Pod

Solve this question on the local cluster.

There is *ServiceAccount* secret-reader in *Namespace* project-swan. Create a *Pod* of image nginx:1-alpine named api-contact which uses this *ServiceAccount*.

Exec into the *Pod* and use curl to manually query all *Secrets* from the Kubernetes Api.

Write the result into file /opt/course/9/result.json.

Course files are under /opt/course/9/
EOF
