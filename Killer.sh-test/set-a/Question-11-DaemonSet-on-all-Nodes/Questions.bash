#!/bin/bash
# Killer.sh Question 11: DaemonSet on all Nodes

cat <<'EOF'
Question 11 | DaemonSet on all Nodes

Solve this question on the local cluster.

Use *Namespace* project-tiger for the following. Create a *DaemonSet* named ds-important with image httpd:2-alpine and labels id=ds-important and uuid=18426a0b-5f59-4e10-923f-c0e078e82462. The *Pods* it creates should request 10 millicore cpu and 10 mebibyte memory. The *Pods* of that *DaemonSet* should run on all nodes, also controlplanes.

Course files are under /opt/course/11/
EOF
