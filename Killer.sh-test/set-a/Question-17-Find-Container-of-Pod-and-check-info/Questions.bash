#!/bin/bash
# Killer.sh Question 17: Find Container of Pod and check info

cat <<'EOF'
Question 17 | Find Container of Pod and check info

Solve this question on the local cluster.

In *Namespace* project-tiger create a *Pod* named tigers-reunite of image httpd:2-alpine with labels pod=container and container=pod. Find out on which node the *Pod* is scheduled. Ssh into that node and find the containerd container belonging to that *Pod*.

Using command crictl:

1. Write the ID of the container and the info.runtimeType into /opt/course/17/pod-container.txt  
2. Write the logs of the container into /opt/course/17/pod-container.log

 

ℹ️ You can connect to a worker node using ssh cka2556-node1 or ssh cka2556-node2 from cka2556

Course files are under /opt/course/17/
EOF
