#!/bin/bash
cat <<'EOF'
Solution notes — Question 17 | Find Container of Pod and check info

ℹ️ In this environment crictl can be used for container management. In the real exam this could also be docker. Both commands can be used with the same arguments.

 

First we create the *Pod*:

pod/tigers-reunite created

Next we find out the node it's scheduled on:

NAME                                   READY   ...   NODE

tigers-for-rent-web-57558cfbf8-4tldr   1/1     ...   cka2556-node1

tigers-for-rent-web-57558cfbf8-5pz4z   1/1     ...   cka2556-node2

tigers-reunite                         1/1     ...   cka2556-node1

Here it's cka2556-node1 so we ssh into that node and and check the container info:

ba62e5d465ff0   a7ccaadd632cf   2 minutes ago   Running   tigers-reunite   ...

 

###### **Step 1**

Having the container we can crictl inspect it for the runtimeType:

   "runtimeType": "io.containerd.runc.v2",

Now we create the requested file on cka2556:

\# cka2556:/opt/course/17/pod-container.txt

ba62e5d465ff0 io.containerd.runc.v2

 

###### **Step 2**

Finally we query the container logs:

AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 10.44.0.29. Set the 'ServerName' directive globally to suppress this message

AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 10.44.0.29. Set the 'ServerName' directive globally to suppress this message

\[Tue Oct 29 15:12:57.211347 2024\] \[mpm_event:notice\] \[pid 1:tid 1\] AH00489: Apache/2.4.62 (Unix) configured -- resuming normal operations

\[Tue Oct 29 15:12:57.211841 2024\] \[core:notice\] \[pid 1:tid 1\] AH00094: Command line: 'httpd -D FOREGROUND'

Here we run crictl logs on the worker node and copy the content manually, that works if it's not a lot of logs. Otherwise we could write the logs into a file on cka2556-node1 and download the file via scp from cka2556.

The file should look like this:

\# cka2556:/opt/course/17/pod-container.log

AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 10.44.0.37. Set the 'ServerName' directive globally to suppress this message

AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 10.44.0.37. Set the 'ServerName' directive globally to suppress this message

\[Mon Sep 13 13:32:18.555280 2021\] \[mpm_event:notice\] \[pid 1:tid 139929534545224\] AH00489: Apache/2.4.41 (Unix) configured -- resuming normal operations

\[Mon Sep 13 13:32:18.555610 2021\] \[core:notice\] \[pid 1:tid 139929534545224\] AH00094: Command line: 'httpd -D FOREGROUND'

 

 

 

 

 

 

 

# **CKA Simulator Preview Kubernetes 1.34**

[https://killer.sh](https://killer.sh/)

 

This is a preview of the CKA Simulator content. The full CKA Simulator is available in two versions: A and B. Each version contains at least 17 different questions. These preview questions are in addition to the provided ones and can also be solved in the interactive environment.

 

 

**Preview Question 1 | ETCD Information**

 

Solve this question on: ssh cka9412

 

The cluster admin asked you to find out the following information about etcd running on cka9412:

* Server private key location  
* Server certificate expiration date  
* Is client certificate authentication enabled

Write these information into /opt/course/p1/etcd-info.txt

 

##### **Answer:**

###### **Find out etcd information**

Let's check the nodes:

NAME            STATUS   ROLES           AGE   VERSION

cka9412         Ready    control-plane   9d    v1.33.1

cka9412-node1   Ready    \<none\>          9d    v1.33.1

First we check how etcd is setup in this cluster:

NAME                              READY   STATUS    RESTARTS     AGE

coredns-6f4c58b94d-djpgr          1/1     Running   0            8d

coredns-6f4c58b94d-ds6ch          1/1     Running   0            8d

etcd-cka9412                      1/1     Running   0            9d

kube-apiserver-cka9412            1/1     Running   0            9d

kube-controller-manager-cka9412   1/1     Running   0            9d

kube-proxy-7zhtk                  1/1     Running   0            9d

kube-proxy-nbzrt                  1/1     Running   0            9d

kube-scheduler-cka9412            1/1     Running   0            9d

weave-net-h7n8j                   2/2     Running   1 (9d ago)   9d

weave-net-rbhgl                   2/2     Running   1 (9d ago)   9d

We see it's running as a *Pod*, more specific a static *Pod*. So we check for the default kubelet directory for static manifests:

/etc/kubernetes/manifests/

/etc/kubernetes/manifests/kube-controller-manager.yaml

/etc/kubernetes/manifests/kube-apiserver.yaml

/etc/kubernetes/manifests/etcd.yaml

/etc/kubernetes/manifests/kube-scheduler.yaml

So we look at the yaml and the parameters with which etcd is started:

\# cka9412:/etc/kubernetes/manifests/etcd.yaml

apiVersion: v1

kind: Pod

metadata:

 annotations:

   kubeadm.kubernetes.io/etcd.advertise-client-urls: https://192.168.100.21:2379

 creationTimestamp: null

 labels:

   component: etcd

   tier: control-plane

 name: etcd

 namespace: kube-system

spec:

 containers:

 - command:

   - etcd

   - --advertise-client-urls=https://192.168.100.21:2379

   - --cert-file=/etc/kubernetes/pki/etcd/server.crt            \# server certificate

   - --client-cert-auth=true                                    \# enabled

   - --data-dir=/var/lib/etcd

   - --experimental-initial-corrupt-check=true

   - --experimental-watch-progress-notify-interval=5s

   - --initial-advertise-peer-urls=https://192.168.100.21:2380

   - --initial-cluster=cka9412=https://192.168.100.21:2380

   - --key-file=/etc/kubernetes/pki/etcd/server.key             \# server private key

   - --listen-client-urls=https://127.0.0.1:2379,https://192.168.100.21:2379

   - --listen-metrics-urls=http://127.0.0.1:2381

   - --listen-peer-urls=https://192.168.100.21:2380

   - --name=cka9412

   - --peer-cert-file=/etc/kubernetes/pki/etcd/peer.crt

   - --peer-client-cert-auth=true

   - --peer-key-file=/etc/kubernetes/pki/etcd/peer.key

   - --peer-trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt

   - --snapshot-count=10000

   - --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt

   image: registry.k8s.io/etcd:3.5.15-0

   imagePullPolicy: IfNotPresent

...

We see that client authentication is enabled and also the requested path to the server private key, now let's find out the expiration of the server certificate:

       Validity

           Not Before: Oct 29 14:14:27 2024 GMT

           Not After : Oct 29 14:19:27 2025 GMT

There we have it. Let's write the information into the requested file:

\# /opt/course/p1/etcd-info.txt

Server private key location: /etc/kubernetes/pki/etcd/server.key

Server certificate expiration date: Oct 29 14:19:27 2025 GMT

Is client certificate authentication enabled: yes

 

 

**Preview Question 2 | Kube-Proxy iptables**

 

Solve this question on: ssh cka3962

 

You're asked to confirm that kube-proxy is running correctly. For this perform the following in *Namespace* project-hamster:

1. Create *Pod* p2-pod with image nginx:1-alpine  
2. Create *Service* p2-service which exposes the *Pod* internally in the cluster on port 3000-\>80  
3. Write the iptables rules of node cka3962 belonging the created *Service* p2-service into file /opt/course/p2/iptables.txt  
4. Delete the *Service* and confirm that the iptables rules are gone again

 

##### **Answer:**

 

###### **Step 1: Create the *Pod***

First we create the *Pod*:

pod/p2-pod created

 

###### **Step 2: Create the *Service***

Next we create the *Service*:

NAME                 READY   STATUS    RESTARTS   AGE

pod/p2-pod           1/1     Running   0          2m31s

NAME                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE

service/p2-service   ClusterIP   10.105.128.247   \<none\>        3000/TCP   1s

We should see that *Pods* and *Services* are connected.

 

###### **(Optional) Confirm kube-proxy is running and is using iptabl
EOF
