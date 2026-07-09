#!/bin/bash
# Killer.sh Question 15: Cluster Event Logging

cat <<'EOF'
Question 15 | Cluster Event Logging

Solve this question on the local cluster.

1. Write a kubectl command into /opt/course/15/cluster_events.sh which shows the latest events in the whole cluster, ordered by time (metadata.creationTimestamp)  
2. Delete the kube-proxy *Pod* and write the events this caused into /opt/course/15/pod_kill.log on this cluster  
3. Manually kill the containerd container of the kube-proxy *Pod* and write the events into /opt/course/15/container_kill.log

Course files are under /opt/course/15/
EOF
