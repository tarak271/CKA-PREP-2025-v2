#!/bin/bash
cat <<'EOF'
Solution notes — Question 14 | Find out Cluster Information

###### **How many controlplane and worker nodes are available?**

NAME      STATUS   ROLES           AGE   VERSION

cka8448   Ready    control-plane   71m   v1.33.1

We see one controlplane and no worker nodes.

 

###### **What is the Service CIDR?**

   - --service-cluster-ip-range=10.96.0.0/12

 

###### **Which Networking (or CNI Plugin) is configured and where is its config file?**

/etc/cni/net.d/

/etc/cni/net.d/.kubernetes-cni-keep

/etc/cni/net.d/10-weave.conflist

/etc/cni/net.d/87-podman-bridge.conflist

{

   "cniVersion": "0.3.0",

   "name": "weave",

   "plugins": \[

       {

           "name": "weave",

           "type": "weave-net",

           "hairpinMode": true

       },

       {

           "type": "portmap",

           "capabilities": {"portMappings": true},

           "snat": true

       }

   \]

}

By default the kubelet looks into /etc/cni/net.d to discover the CNI plugins. This will be the same on every controlplane and worker nodes.

 

###### **Which suffix will static pods have that run on cka8448?**

The suffix is the node hostname with a leading hyphen.

 

###### **Result**

The resulting /opt/course/14/cluster-info could look like:

\# /opt/course/14/cluster-info

\# How many controlplane nodes are available?

1: 1

\# How many worker nodes (non controlplane nodes) are available?

2: 0

\# What is the Service CIDR?

3: 10.96.0.0/12

\# Which Networking (or CNI Plugin) is configured and where is its config file?

4: Weave, /etc/cni/net.d/10-weave.conflist

\# Which suffix will static pods have that run on cka8448?

5: -cka8448
EOF
