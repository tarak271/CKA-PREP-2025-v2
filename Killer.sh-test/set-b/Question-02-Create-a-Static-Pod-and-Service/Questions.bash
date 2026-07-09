#!/bin/bash
# Killer.sh Question 02: Create a Static Pod and Service

cat <<'EOF'
Question 2 | Create a Static Pod and Service

Solve this question on the local cluster.

Create a Static Pod named my-static-pod in *Namespace* default on the controlplane node. It should be of image nginx:1-alpine and have resource requests for 10m CPU and 20Mi memory.

Create a NodePort *Service* named static-pod-service which exposes that static *Pod* on port 80.

 

ℹ️ For verification check if the new *Service* has one *Endpoint*. It should also be possible to access the *Pod* via the cka2560 internal IP address, like using curl 192.168.100.31:NODE_PORT

Course files are under /opt/course/2/
EOF
