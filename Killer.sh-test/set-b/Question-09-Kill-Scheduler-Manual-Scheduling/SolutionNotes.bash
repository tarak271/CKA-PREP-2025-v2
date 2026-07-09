#!/bin/bash
cat <<'EOF'
Solution notes — Question 9 | Kill Scheduler, Manual Scheduling

###### **Stop the Scheduler**

First we find the controlplane node:

NAME            STATUS   ROLES           AGE     VERSION

cka5248         Ready    control-plane   6d22h   v1.33.1

cka5248-node1   Ready    \<none\>          6d22h   v1.33.1

Then we connect and check if the scheduler is running:

kube-scheduler-cka5248            1/1     Running   0               6d22h

Kill the Scheduler (temporarily):

And it should be stopped, we can wait for the container to be removed with watch crictl ps:

ℹ️ In this environment crictl can be used for container management. In the real exam this could also be docker. Both commands can be used with the same arguments.

 

###### **Create a *Pod***

Now we create the *Pod*:

pod/manual-schedule created

And confirm it has no node assigned:

NAME              READY   STATUS    RESTARTS   AGE   IP       NODE    ...

manual-schedule   0/1     Pending   0          14s   \<none\>   \<none\>  ...

 

###### **Manually schedule the *Pod***

Let's play the scheduler now:

\# cka5248:/root/9.yaml

apiVersion: v1

kind: Pod

metadata:

 creationTimestamp: "2020-09-04T15:51:02Z"

 labels:

   run: manual-schedule

 managedFields:

...

   manager: kubectl-run

   operation: Update

   time: "2020-09-04T15:51:02Z"

 name: manual-schedule

 namespace: default

 resourceVersion: "3515"

 selfLink: /api/v1/namespaces/default/pods/manual-schedule

 uid: 8e9d2532-4779-4e63-b5af-feb82c74a935

spec:

 nodeName: cka5248    \# ADD the controlplane node name

 containers:

 - image: httpd:2-alpine

   imagePullPolicy: IfNotPresent

   name: manual-schedule

   resources: {}

   terminationMessagePath: /dev/termination-log

   terminationMessagePolicy: File

   volumeMounts:

   - mountPath: /var/run/secrets/kubernetes.io/serviceaccount

     name: default-token-nxnc7

     readOnly: true

 dnsPolicy: ClusterFirst

...

The scheduler sets the nodeName for a *Pod* declaration. How it finds the correct node to schedule on, that's a very much complicated matter and takes many variables into account.

As we cannot kubectl apply or kubectl edit , in this case we need to delete and create or replace:

How does it look?

NAME              READY   STATUS    ...   NODE            

manual-schedule   1/1     Running   ...   cka5248

It looks like our *Pod* is running on the controlplane now as requested, although no tolerations were specified. Only the scheduler takes taints/tolerations/affinity into account when finding the correct node name. That's why it's still possible to assign *Pods* manually directly to a controlplane node and skip the scheduler.

 

###### **Start the scheduler again**

Checks it's running:

kube-scheduler-cka5248            1/1     Running   0               13s

Schedule a second test *Pod*:

manual-schedule    1/1     Running   0          95s   10.32.0.2   cka5248

manual-schedule2   1/1     Running   0          9s    10.44.0.3   cka5248-node1

Back to normal.
EOF
