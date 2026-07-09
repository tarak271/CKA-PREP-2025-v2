#!/bin/bash
cat <<'EOF'
Solution notes — Question 8 | Update Kubernetes Version and join cluster

###### **Update Kubernetes to controlplane version**

Search in the docs for [kubeadm upgrade](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade):

NAME      STATUS   ROLES           AGE   VERSION

cka3962   Ready    control-plane   19h   v1.34.1

The controlplane node seems to be running Kubernetes 1.34.1.

Client Version: v1.33.5

Kustomize Version: v5.6.0

The connection to the server localhost:8080 was refused - did you specify the right host or port?

Kubernetes v1.33.5

kubeadm version: \&version.Info{Major:"1", Minor:"34", EmulationMajor:"", EmulationMinor:"", MinCompatibilityMajor:"", MinCompatibilityMinor:"", GitVersion:"v1.34.1", GitCommit:"93248f9ae092f571eb870b7664c534bfc7d00f03", GitTreeState:"clean", BuildDate:"2025-09-09T19:43:15Z", GoVersion:"go1.24.6", Compiler:"gc", Platform:"linux/amd64"}

Above we can see that kubeadm is already installed in the exact needed version, otherwise we would need to install it using apt install kubeadm=1.34.1-1.1.

With the correct kubeadm version we can continue:

error: couldn't create a Kubernetes client from file "/etc/kubernetes/kubelet.conf": failed to load admin kubeconfig: open /etc/kubernetes/kubelet.conf: no such file or directory

To see the stack trace of this error execute with --v=5 or higher

This is usually the proper command to upgrade a worker node. But as mentioned in the question description, this node is not yet part of the cluster. Hence there is nothing to update. We'll add the node to the cluster later using kubeadm join. For now we can continue with updating kubelet and kubectl:

Hit:1 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.34/deb  InRelease

Hit:2 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.33/deb  InRelease

Reading package lists... Done

Building dependency tree... Done

Reading state information... Done

2 packages can be upgraded. Run 'apt list --upgradable' to see them.

Version: 1.34.1-1.1

APT-Sources: https://pkgs.k8s.io/core:/stable:/v1.34/deb  Packages

Version: 1.34.0-1.1

APT-Sources: https://pkgs.k8s.io/core:/stable:/v1.34/deb  Packages

Reading package lists... Done

Building dependency tree... Done

Reading state information... Done

The following packages were automatically installed and are no longer required:

 libevent-core-2.1-7t64 libjq1 libonig5 pastebinit python3-newt run-one squashfs-tools

Use 'apt autoremove' to remove them.

The following packages will be upgraded:

 kubectl kubelet

2 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.

Need to get 24.7 MB of archives.

After this operation, 22.1 MB disk space will be freed.

Get:1 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.34/deb  kubectl 1.34.1-1.1 \[11.7 MB\]

Get:2 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.34/deb  kubelet 1.34.1-1.1 \[13.0 MB\]

Fetched 24.7 MB in 1s (29.5 MB/s)

(Reading database ... 72153 files and directories currently installed.)

Preparing to unpack .../kubectl_1.34.1-1.1_amd64.deb ...

Unpacking kubectl (1.34.1-1.1) over (1.33.5-1.1) ...

Preparing to unpack .../kubelet_1.34.1-1.1_amd64.deb ...

Unpacking kubelet (1.34.1-1.1) over (1.33.5-1.1) ...

Setting up kubectl (1.34.1-1.1) ...

Setting up kubelet (1.34.1-1.1) ...

Scanning processes...                                                                                                                                                  

Scanning linux images...                                                                                                                                            

Running kernel seems to be up-to-date.

No services need to be restarted.

No containers need to be restarted.

No user sessions are running outdated binaries.

No VM guests are running outdated hypervisor (qemu) binaries on this host.

Kubernetes v1.34.1

Now that we're up to date with kubeadm, kubectl and kubelet we can restart the kubelet:

● kubelet.service - kubelet: The Kubernetes Node Agent

    Loaded: loaded (/usr/lib/systemd/system/kubelet.service; enabled; preset: enabled)

   Drop-In: /usr/lib/systemd/system/kubelet.service.d

            └─10-kubeadm.conf

    Active: activating (auto-restart) (Result: exit-code) since Fri 2025-09-19 13:13:26 UTC; 8s ago

      Docs: https://kubernetes.io/docs/

   Process: 12623 ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS (code=exited, status=1/FAILURE)

  Main PID: 12623 (code=exited, status=1/FAILURE)

       CPU: 118ms

These errors occur because we still need to run kubeadm join to join the node into the cluster. Let's do this in the next step.

 

###### **Add cka3962-node1 to cluster**

First we log into the controlplane node and generate a new TLS bootstrap token, also printing out the join command:

kubeadm join 192.168.100.31:6443 --token czqy6e.9k8ntd6oobw5tah7 --discovery-token-ca-cert-hash sha256:eae79e9d840dcfee86ef40b0ba6c0b29e2131575ff4f5fe21ab21e1236bba056

TOKEN                     TTL         EXPIRES                ...

0w1k1l.1ev0hyn2g4l2eqbk   \<forever\>   \<never\>                ...

8dt86t.0mpjulubm3zol0xl   4h          2025-09-19T17:22:52Z   ...

czqy6e.9k8ntd6oobw5tah7   23h         2025-09-20T13:13:53Z   ...

We see the expiration of 23h for our token, we could adjust this by passing the ttl argument.

Next we connect again to cka3962-node1 and simply execute the join command from above:

\[preflight\] Running pre-flight checks

\[preflight\] Reading configuration from the "kubeadm-config" ConfigMap in namespace "kube-system"...

\[preflight\] Use 'kubeadm init phase upload-config kubeadm --config your-config-file' to re-upload it.

\[kubelet-start\] Writing kubelet configuration to file "/var/lib/kubelet/instance-config.yaml"

\[patches\] Applied patch of type "application/strategic-merge-patch+json" to target "kubeletconfiguration"

\[kubelet-start\] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"

\[kubelet-start\] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"

\[kubelet-start\] Starting the kubelet

\[kubelet-check\] Waiting for a healthy kubelet at http://127.0.0.1:10248/healthz. This can take up to 4m0s

\[kubelet-check\] The kubelet is healthy after 1.514141935s

\[kubelet-start\] Waiting for the kubelet to perform the TLS Bootstrap

This node has joined the cluster:

* Certificate signing request was sent to apiserver and a response was received.

* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.

● kubelet.service - kubelet: The Kubernetes Node Agent

    Loaded: loaded (/usr/lib/systemd/system/kubelet.service; enabled; preset: enabled)

   Drop-In: /usr/lib/systemd/system/kubelet.service.d

            └─10-kubeadm.conf

    Active: active (running) since Fri 2025-09-19 13:15:32 UTC; 13s ago

      Docs: https://kubernetes.io/docs/

  Main PID: 12826 (kubelet)

     Tasks: 11 (limit: 1113\)

    Memory: 22.4M (peak: 22.6M)

       CPU: 2.296s

    CGroup: /system.slice/kubelet.service

            └─12826 /usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --config=/var/lib/kubele\>

...

ℹ️ If you have troubles with kubeadm join you might need to run kubeadm reset before

Finally we check the node status:

NAME            STATUS     ROLES           AGE   VERSION

cka3962         Ready      control-plane   19h   v1.34.1

cka3962-node1   NotReady   \<none\>          10s   v1.34.1

Give it a bit of time till the node is ready.

NAME            STATUS   ROLES           AGE   VERSION

cka3962         Ready    control-plane   19h   v1.34.1

cka3962-node1   Ready    \<none\>          24s   v1.34.1

We see cka3962-node1 is now available and up to date.
EOF
