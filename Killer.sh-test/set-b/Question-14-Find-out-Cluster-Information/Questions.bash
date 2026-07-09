#!/bin/bash
# Killer.sh Question 14: Find out Cluster Information

cat <<'EOF'
Question 14 | Find out Cluster Information

Solve this question on the local cluster.

You're ask to find out following information about the cluster:

1. How many controlplane nodes are available?  
2. How many worker nodes (non controlplane nodes) are available?  
3. What is the Service CIDR?  
4. Which Networking (or CNI Plugin) is configured and where is its config file?  
5. Which suffix will static pods have that run on this cluster?

Write your answers into file /opt/course/14/cluster-info, structured like this:

\# /opt/course/14/cluster-info

1: \[ANSWER\]

2: \[ANSWER\]

3: \[ANSWER\]

4: \[ANSWER\]

5: \[ANSWER\]

Course files are under /opt/course/14/
EOF
