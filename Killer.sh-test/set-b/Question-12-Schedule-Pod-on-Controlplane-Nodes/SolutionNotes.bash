#!/bin/bash
cat <<'EOF'
Solution notes — Question 12 | Schedule Pod on Controlplane Nodes

First we find the controlplane node(s) and their taints:

NAME            STATUS   ROLES           AGE   VERSION

cka5248         Ready    control-plane   90m   v1.33.1

cka5248-node1   Ready    \<none\>          85m   v1.33.1

Taints:             node-role.kubernetes.io/control-plane:NoSchedule

Unschedulable:      false

NAME      STATUS   ROLES           AGE   VERSION   LABELS

cka5248   Ready    control-plane   91m   v1.33.1   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=cka5248,kubernetes.io/os=linux,node-role.kubernetes.io/control-plane=,node.kubernetes.io/exclude-from-external-load-balancers=

Next we create the *Pod* yaml:

 

###### **Solution using NodeSelector**

Use the K8s docs and search for tolerations and nodeSelector to find examples, then update:

\# cka5248:/home/candidate/12.yaml

apiVersion: v1

kind: Pod

metadata:

 creationTimestamp: null

 labels:

   run: pod1

 name: pod1

spec:

 containers:

 - image: httpd:2-alpine

   name: pod1-container                       \# change

   resources: {}

 dnsPolicy: ClusterFirst

 restartPolicy: Always

 tolerations:                                 \# add

 - effect: NoSchedule                         \# add

   key: node-role.kubernetes.io/control-plane \# add

 nodeSelector:                                \# add

   node-role.kubernetes.io/control-plane: ""  \# add

status: {}

ℹ️ The nodeSelector specifies node-role.kubernetes.io/control-plane with no value because this is a key-only label and we want to match regardless of the value

Important here to add the toleration for running on controlplane nodes, but also the nodeSelector to make sure it **only** runs on controlplane nodes. If we just specify a toleration the *Pod* can be scheduled on controlplane or worker nodes.

 

###### **Solution using NodeAffinity**

We could also use nodeAffinity instead of nodeSelector, although in this case it is more complex and not really suggested:

\# cka5248:/home/candidate/12.yaml

apiVersion: v1

kind: Pod

metadata:

 creationTimestamp: null

 labels:

   run: pod1

 name: pod1

spec:

 containers:

 - image: httpd:2-alpine

   name: pod1-container                       \# change

   resources: {}

 dnsPolicy: ClusterFirst

 restartPolicy: Always

 tolerations:                                 \# add

 - effect: NoSchedule                         \# add

   key: node-role.kubernetes.io/control-plane \# add

 affinity:                                            \# add

   nodeAffinity:                                      \# add

     requiredDuringSchedulingIgnoredDuringExecution:  \# add

       nodeSelectorTerms:                             \# add

       - matchExpressions:                            \# add

         - key: node-role.kubernetes.io/control-plane \# add

           operator: Exists                           \# add

status: {}

Using nodeAffinity still requires the toleration.

 

###### **Verify**

Now we create the *Pod* and and check if is scheduled:

pod/pod1 created

NAME   READY   STATUS    ...   NODE      NOMINATED NODE   READINESS GATES

pod1   1/1     Running   ...   cka5248   \<none\>           \<none\>

We can see the *Pod* is scheduled on the controlplane node.
EOF
