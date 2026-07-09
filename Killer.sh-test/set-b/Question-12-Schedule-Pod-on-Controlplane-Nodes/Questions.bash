#!/bin/bash
# Killer.sh Question 12: Schedule Pod on Controlplane Nodes

cat <<'EOF'
Question 12 | Schedule Pod on Controlplane Nodes

Solve this question on the local cluster.

Create a *Pod* of image httpd:2-alpine in *Namespace* default.

The *Pod* should be named pod1 and the container should be named pod1-container.

This *Pod* should **only** be scheduled on controlplane nodes.

Do **not** add new labels to any nodes.

Course files are under /opt/course/12/
EOF
