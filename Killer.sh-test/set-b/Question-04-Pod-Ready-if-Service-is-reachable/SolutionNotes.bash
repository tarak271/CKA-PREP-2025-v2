#!/bin/bash
cat <<'EOF'
Solution notes — Question 4 | Pod Ready if Service is reachable

It's a bit of an anti-pattern for one *Pod* to check another *Pod* for being ready using probes, hence the normally available readinessProbe.httpGet doesn't work for absolute remote urls. Still the workaround requested in this task should show how probes and *Pod*\<-\>*Service* communication works.

First we create the first *Pod*:

Next perform the necessary additions manually:

\# cka3200:/home/candidate/4_pod1.yaml

apiVersion: v1

kind: Pod

metadata:

 creationTimestamp: null

 labels:

   run: ready-if-service-ready

 name: ready-if-service-ready

spec:

 containers:

 - image: nginx:1-alpine

   name: ready-if-service-ready

   resources: {}

   livenessProbe:                                      \# add from here

     exec:

       command:

       - 'true'

   readinessProbe:

     exec:

       command:

       - sh

       - -c

       - 'wget -T2 -O- http://service-am-i-ready:80'   \# to here

 dnsPolicy: ClusterFirst

 restartPolicy: Always

status: {}

Then create the *Pod* and confirm it's in a non-ready state:

pod/ready-if-service-ready created

NAME                     READY   STATUS    RESTARTS   AGE

ready-if-service-ready   0/1     Running   0          8s

We can also check the reason for this using describe:

...

 Warning  Unhealthy  7s (x4 over 23s)  kubelet            Readiness probe failed: command timed out: "sh -c wget -T2 -O- http://service-am-i-ready:80" timed out after 1s

Now we create the second *Pod*:

pod/am-i-ready created

The already existing *Service* service-am-i-ready should now have an *Endpoint*:

Name:                     service-am-i-ready

Namespace:                default

Labels:                   id=cross-server-ready

Annotations:              \<none\>

Selector:                 id=cross-server-ready

Type:                     ClusterIP

IP Family Policy:         SingleStack

IP Families:              IPv4

IP:                       10.108.19.168

IPs:                      10.108.19.168

Port:                     \<unset\>  80/TCP

TargetPort:               80/TCP

Endpoints:                10.44.0.30:80

Session Affinity:         None

Internal Traffic Policy:  Cluster

Events:                   \<none\>

NAME                       ADDRESSTYPE   PORTS   ENDPOINTS    AGE

service-am-i-ready-ch6d6   IPv4          80      10.44.0.30   6d19h

Which will result in our first *Pod* being ready, just give it a minute for the Readiness probe to check again:

NAME                     READY   STATUS    RESTARTS   AGE

ready-if-service-ready   1/1     Running   0          2m10s

Look at these *Pods* working together\!
EOF
