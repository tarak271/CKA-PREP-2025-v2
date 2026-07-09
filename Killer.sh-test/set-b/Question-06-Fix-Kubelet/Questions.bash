#!/bin/bash
# Killer.sh Question 06: Fix Kubelet

cat <<'EOF'
Question 6 | Fix Kubelet

Solve this question on the local cluster.

There seems to be an issue with the kubelet on controlplane node cka1024, it's not running.

Fix the kubelet and confirm that the node is available in Ready state.

Create a *Pod* called success in default *Namespace* of image nginx:1-alpine.

 

ℹ️ The node has no taints and can schedule *Pods* without additional tolerations

Course files are under /opt/course/6/
EOF
