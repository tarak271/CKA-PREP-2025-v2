#!/bin/bash
cat <<'EOF'
Solution notes — Question 11 | DaemonSet on all Nodes

As of now we aren't able to create a *DaemonSet* directly using kubectl, so we create a *Deployment* and just change it up:

Or we could search for a *DaemonSet* example yaml in the K8s docs and alter it to our needs.

We adjust the yaml to:

\# cka2556:/home/candidate/11.yaml

apiVersion: apps/v1

kind: DaemonSet                   \# change from Deployment to Daemonset

metadata:

 creationTimestamp: null

 labels:                                           \# add

   id: ds-important                                \# add

   uuid: 18426a0b-5f59-4e10-923f-c0e078e82462    \# add

 name: ds-important

 namespace: project-tiger              \# important

spec:

 \#replicas: 1                    \# remove

 selector:

   matchLabels:

     id: ds-important                \# add

     uuid: 18426a0b-5f59-4e10-923f-c0e078e82462   \# add

 \#strategy: {}                   \# remove

 template:

   metadata:

     creationTimestamp: null

     labels:

       id: ds-important               \# add

       uuid: 18426a0b-5f59-4e10-923f-c0e078e82462  \# add

   spec:

     containers:

     - image: httpd:2-alpine

       name: ds-important

       resources:

         requests:                 \# add

           cpu: 10m                 \# add

           memory: 10Mi               \# add

     tolerations:                               \# add

     - effect: NoSchedule                       \# add

       key: node-role.kubernetes.io/control-plane  \# add

\#status: {}                     \# remove

It was requested that the *DaemonSet* runs on all nodes, so we need to specify the toleration for this.

Let's give it a go:

daemonset.apps/ds-important created

NAME           DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE

ds-important   3         3         3       3            3           \<none\>          8s

NAME                 READY   STATUS    ...    NODE            ...

ds-important-26456   1/1     Running   ...    cka2556-node2   ...

ds-important-wnt5p   1/1     Running   ...    cka2556         ...

ds-important-wrbjd   1/1     Running   ...    cka2556-node1   ...

Above we can see one *Pod* on each node, including the controlplane one.
EOF
