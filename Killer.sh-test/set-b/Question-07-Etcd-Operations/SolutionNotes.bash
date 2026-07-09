#!/bin/bash
cat <<'EOF'
Solution notes — Question 7 | Etcd Operations

###### **Step 1: Etcd Version**

Here we simply need to execute a command, shouldn't be that hard:

Command 'etcd' not found, but can be installed with:

apt install etcd-server

Well, etcd is not installed directly on the controlplane but it runs as a *Pod* instead. So we do:

root@cka2560:\~\# k -n kube-system get pod

NAME                              READY   STATUS    RESTARTS      AGE

coredns-78c4c75bb8-fgkfv          1/1     Running   0             15d

coredns-78c4c75bb8-l7mmh          1/1     Running   0             15d

etcd-cka2560                      1/1     Running   0             13m

kube-apiserver-cka2560            1/1     Running   0             15d

kube-controller-manager-cka2560   1/1     Running   0             15d

kube-proxy-f56td                  1/1     Running   0             15d

kube-scheduler-cka2560            1/1     Running   0             15d

weave-net-44k9c                   2/2     Running   1 (15d ago)   15d

root@cka2560:\~\# k -n kube-system exec etcd-cka2560 -- etcd --version

etcd Version: 3.6.4

Git SHA: 5400cdc

Go Version: go1.23.11

Go OS/Arch: linux/amd64

root@cka2560:\~\# k -n kube-system exec etcd-cka2560 -- etcd --version \> /opt/course/7/etcd-version

 

###### **Step 2: Etcd Snapshot**

First we log into the controlplane and try to create a snapshot of etcd:

{"level":"info","ts":"2024-11-07T14:02:17.746254Z","caller":"snapshot/v3_snapshot.go:65","msg":"created temporary db file","path":"/opt/course/7/etcd-snapshot.db.part"}

^C

But it fails or hangs because we need to authenticate ourselves. For the necessary information we can check the etc manifest:

We only check the etcd.yaml for necessary information we don't change it.

\# cka2560:/etc/kubernetes/manifests/etcd.yaml

apiVersion: v1

kind: Pod

metadata:

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

   - --advertise-client-urls=https://192.168.100.31:2379

   - --cert-file=/etc/kubernetes/pki/etcd/server.crt              \# use

   - --client-cert-auth=true

   - --data-dir=/var/lib/etcd

   - --initial-advertise-peer-urls=https://192.168.100.31:2380

   - --initial-cluster=cka2560=https://192.168.100.31:2380

   - --key-file=/etc/kubernetes/pki/etcd/server.key               \# use

   - --listen-client-urls=https://127.0.0.1:2379,https://192.168.100.31:2379  \# use

   - --listen-metrics-urls=http://127.0.0.1:2381

   - --listen-peer-urls=https://192.168.100.31:2380

   - --name=cka2560

   - --peer-cert-file=/etc/kubernetes/pki/etcd/peer.crt

   - --peer-client-cert-auth=true

   - --peer-key-file=/etc/kubernetes/pki/etcd/peer.key

   - --peer-trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt           \# use

   - --snapshot-count=10000

   - --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt

   image: k8s.gcr.io/etcd:3.3.15-0

   imagePullPolicy: IfNotPresent

   livenessProbe:

     failureThreshold: 8

     httpGet:

       host: 127.0.0.1

       path: /health

       port: 2381

       scheme: HTTP

     initialDelaySeconds: 15

     timeoutSeconds: 15

   name: etcd

   resources: {}

   volumeMounts:

   - mountPath: /var/lib/etcd

     name: etcd-data

   - mountPath: /etc/kubernetes/pki/etcd

     name: etcd-certs

 hostNetwork: true

 priorityClassName: system-cluster-critical

 volumes:

 - hostPath:

     path: /etc/kubernetes/pki/etcd

     type: DirectoryOrCreate

   name: etcd-certs

 - hostPath:

     path: /var/lib/etcd                           \# important

     type: DirectoryOrCreate

   name: etcd-data

status: {}

But we also know that the api-server is connecting to etcd, so we can check how its manifest is configured:

   - --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt

   - --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt

   - --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key

   - --etcd-servers=https://127.0.0.1:2379

We use the authentication information and pass it to etcdctl:

ETCDCTL_API=3 etcdctl snapshot save /opt/course/7/etcd-snapshot.db \\

--cacert /etc/kubernetes/pki/etcd/ca.crt \\

--cert /etc/kubernetes/pki/etcd/server.crt \\

--key /etc/kubernetes/pki/etcd/server.key

Which should provide successful output:

--cacert /etc/kubernetes/pki/etcd/ca.crt \\

--cert /etc/kubernetes/pki/etcd/server.crt \\

--key /etc/kubernetes/pki/etcd/server.key

{"level":"info","ts":"2025-03-02T13:35:48.806437Z","caller":"snapshot/v3_snapshot.go:65","msg":"created temporary db file","path":"/opt/course/7/etcd-snapshot.db.part"}

{"level":"info","ts":"2025-03-02T13:35:48.929550Z","logger":"client","caller":"v3@v3.5.16/maintenance.go:212","msg":"opened snapshot stream; downloading"}

{"level":"info","ts":"2025-03-02T13:35:48.929975Z","caller":"snapshot/v3_snapshot.go:73","msg":"fetching snapshot","endpoint":"127.0.0.1:2379"}

{"level":"info","ts":"2025-03-02T13:35:49.110620Z","logger":"client","caller":"v3@v3.5.16/maintenance.go:220","msg":"completed snapshot read; closing"}

{"level":"info","ts":"2025-03-02T13:35:49.155626Z","caller":"snapshot/v3_snapshot.go:88","msg":"fetched snapshot","endpoint":"127.0.0.1:2379","size":"2.4 MB","took":"now"}

{"level":"info","ts":"2025-03-02T13:35:49.155886Z","caller":"snapshot/v3_snapshot.go:97","msg":"saved","path":"/opt/course/7/etcd-snapshot.db"}

Snapshot saved at /opt/course/7/etcd-snapshot.db

ℹ️ Don't use snapshot status because it can alter the snapshot file and render it invalid in certain etcd versions

 

###### **(Optional) Etcd Restore**

ℹ️ Doing this wrong can leave this cluster broken and will affect this question and also others

We create a *Pod* in the cluster and wait for it to be running:

pod/test created

NAME   READY   STATUS    RESTARTS   AGE

test   1/1     Running   0          17s

Next we stop all controlplane components:

It's **very important** to wait for all K8s controlplane containers to be removed before continuing. This can take a minute\!

ℹ️ In this environment crictl can be used for container management. In the real exam this could also be docker. Both commands can be used with the same arguments.

Now we restore the snapshot into a specific directory:

Deprecated: Use \`etcdutl snapshot restore\` instead.

2025-03-02T13:38:07Z    info    snapshot/v3_snapshot.go:265     restoring snapshot      {"path": "/opt/course/7/etcd-snapshot.db", "wal-dir": "/var/lib/etcd-snapshot/member/wal", "data-dir": "/var/lib/etcd-snapshot", "snap-dir": "/var/lib/etcd-snapshot/member/snap", "initial-memory-map-size": 0}

2025-03-02T13:38:07Z    info    membership/store.go:141 Trimming membership information from the backend...

2025-03-02T13:38:07Z    info    membership/cluster.go:421       added member    {"cluster-id": "cdf818194e3a8c32", "local-member-id": "0", "added-peer-id": "8e9e05c52164694d", "added-peer-peer-urls": \["http://localhost:2380"\]}

2025-03-02T13:38:08Z    info    snapshot/v3_snapshot.go:293     restored snapshot       {"path": "/opt/course/7/etcd-snapshot.db", "wal-dir": "/var/lib/etcd-snapshot/member/wal", "data-dir": "/var/lib/etcd-snapshot", "snap-dir": "/var/lib/etcd-snapshot/member/snap", "initial-memory-map-size": 0}

We could specify another host to make the backup from by using etcdctl --endpoints http://IP, but here we just use the default value which is: http://127.0.0.1:2379,http://127.0.0.1:4001.

The restored files are located at the new folder /var/lib/etcd-snapshot, now we have to tell etcd to use that directory:

\# /etc/kubernetes/etcd.yaml

apiVersion: v1

kind: Pod

metadata:

 creationTimestamp: null

 labels:

   component: etcd

   tier: control-plane

 name: etcd

 namespace: kube-system

spec:

...

   - mountPath: /etc/kubernetes/pki/etcd

     name: etcd-certs

 hostNetwork: true

 priorityClassName: system-cluster-critical

 volumes:

 - hostPath:

     path: /etc/kubernetes/pki/etcd

     type: DirectoryOrCreate

   name: etcd-certs

 - hostPath:

     path: /var/lib/etcd-snaps
EOF
