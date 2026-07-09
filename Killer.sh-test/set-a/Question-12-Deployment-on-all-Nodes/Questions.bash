#!/bin/bash
# Killer.sh Question 12: Deployment on all Nodes

cat <<'EOF'
Question 12 | Deployment on all Nodes

Solve this question on the local cluster.

Implement the following in *Namespace* project-tiger:

* Create a *Deployment* named deploy-important with 3 replicas  
* The *Deployment* and its *Pods* should have label id=very-important  
* First container named container1 with image nginx:1-alpine  
* Second container named container2 with image google/pause  
* There should only ever be **one** *Pod* of that *Deployment* running on **one** worker node, use topologyKey: kubernetes.io/hostname for this

 

ℹ️ Because there are two worker nodes and the *Deployment* has three replicas the result should be that the third *Pod* won't be scheduled. In a way this scenario simulates the behaviour of a *DaemonSet*, but using a *Deployment* with a fixed number of replicas

Course files are under /opt/course/12/
EOF
