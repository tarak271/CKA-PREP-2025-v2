#!/bin/bash
# Killer.sh Question 09: Kill Scheduler, Manual Scheduling

cat <<'EOF'
Question 9 | Kill Scheduler, Manual Scheduling

Solve this question on the local cluster.

**Temporarily** stop the kube-scheduler, this means in a way that you can start it again afterwards.

Create a single *Pod* named manual-schedule of image httpd:2-alpine, confirm it's created but not scheduled on any node.

Now you're the scheduler and have all its power, manually schedule that *Pod* on node cka5248. Make sure it's running.

Start the kube-scheduler again and confirm it's running correctly by creating a second *Pod* named manual-schedule2 of image httpd:2-alpine and check if it's running on this cluster.

Course files are under /opt/course/9/
EOF
