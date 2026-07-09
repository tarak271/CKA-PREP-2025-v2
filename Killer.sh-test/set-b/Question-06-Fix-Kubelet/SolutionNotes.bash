#!/bin/bash
cat <<'EOF'
Solution notes — Question 6 | Fix Kubelet

The procedure on scenarios like these is to first check if the kubelet is running. If it isn't start it, check its logs and fix issues if there are some. It could also be helpful to look at the config files of other clusters and diff/compare.

 

###### **Investigate**

Check node status:

E0423 12:27:08.326639   12871 memcache.go:265\] "Unhandled Error" err="couldn't get current server API group list: Get \\"https://192.168.100.41:6443/api?timeout=32s\\": dial tcp 192.168.100.41:6443: connect: connection refused"

E0423 12:27:08.329430   12871 memcache.go:265\] "Unhandled Error" err="couldn't get current server API group list: Get \\"https://192.168.100.41:6443/api?timeout=32s\\": dial tcp 192.168.100.41:6443: connect: connection refused"

E0423 12:27:08.332448   12871 memcache.go:265\] "Unhandled Error" err="couldn't get current server API group list: Get \\"https://192.168.100.41:6443/api?timeout=32s\\": dial tcp 192.168.100.41:6443: connect: connection refused"

E0423 12:27:08.335352   12871 memcache.go:265\] "Unhandled Error" err="couldn't get current server API group list: Get \\"https://192.168.100.41:6443/api?timeout=32s\\": dial tcp 192.168.100.41:6443: connect: connection refused"

E0423 12:27:08.342153   12871 memcache.go:265\] "Unhandled Error" err="couldn't get current server API group list: Get \\"https://192.168.100.41:6443/api?timeout=32s\\": dial tcp 192.168.100.41:6443: connect: connection refused"

The connection to the server 192.168.100.41:6443 was refused - did you specify the right host or port?

Okay, this looks very wrong. First we check if the kubelet is running:

root       12892  0.0  0.1   7076  ...  0:00 grep --color=auto kubelet

No kubectl process running, just the grep command itself is displayed. We check if the kubelet is configured as service, which is default for a kubeadm installation:

○ kubelet.service - kubelet: The Kubernetes Node Agent

    Loaded: loaded (/usr/lib/systemd/system/kubelet.service; enabled; preset: enabled)

   Drop-In: /usr/lib/systemd/system/kubelet.service.d

            └─10-kubeadm.conf

    Active: inactive (dead) since Sun 2025-03-23 08:16:52 UTC; 1 month 0 days ago

  Duration: 2min 46.830s

      Docs: https://kubernetes.io/docs/

  Main PID: 7346 (code=exited, status=0/SUCCESS)

       CPU: 5.956s

...

We can see it's not running (inactive) in this line:

Active: inactive (dead) since Sun 2025-03-23 08:16:52 UTC; 1 month 0 days ago

But the kubelet is configured as a service with config at /usr/lib/systemd/system/kubelet.service, let's try to start it:

● kubelet.service - kubelet: The Kubernetes Node Agent

    Loaded: loaded (/usr/lib/systemd/system/kubelet.service; enabled; preset: enabled)

   Drop-In: /usr/lib/systemd/system/kubelet.service.d

            └─10-kubeadm.conf

    Active: activating (auto-restart) (Result: exit-code) since Wed 2025-04-23 12:31:07 UTC; 2s ago

      Docs: https://kubernetes.io/docs/

   Process: 13014 ExecStart=/usr/local/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EX\>

  Main PID: 13014 (code=exited, status=203/EXEC)

       CPU: 10ms

Apr 23 12:31:07 cka1024 systemd\[1\]: kubelet.service: Failed with result 'exit-code'.

Above we see it's trying to execute /usr/local/bin/kubelet in this line:

Process: 13014 ExecStart=/usr/local/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EX\>

It does so with some arguments defined in its service config file. A good way to find errors and get more info is to run the command manually:

-bash: /usr/local/bin/kubelet: No such file or directory

kubelet: /usr/bin/kubelet

That's the issue: wrong path to the kubelet binary.

 

###### **Read Logs**

Usually we need to dig a bit deeper and check logs using journalctl -u kubelet or cat /var/log/syslog | grep kubelet:

2025-03-23T08:13:26.775366+00:00 ubuntu systemd\[1\]: Started kubelet.service - kubelet: The Kubernetes Node Agent.

2025-03-23T08:13:26.782571+00:00 ubuntu (kubelet)\[6826\]: kubelet.service: Referenced but unset environment variable evaluates to an empty string: KUBELET_KUBEADM_ARGS

...

2025-04-23T12:31:48.264234+00:00 ubuntu systemd\[1\]: kubelet.service: Scheduled restart job, restart counter is at 5\.

2025-04-23T12:31:48.272108+00:00 ubuntu systemd\[1\]: Started kubelet.service - kubelet: The Kubernetes Node Agent.

2025-04-23T12:31:48.284966+00:00 ubuntu systemd\[1\]: kubelet.service: Main process exited, code=exited, status=203/EXEC

2025-04-23T12:31:48.285487+00:00 ubuntu systemd\[1\]: kubelet.service: Failed with result 'exit-code'.

If we check logs we should always look at the time, we probably only want the latest ones. Here we see:

kubelet.service: Main process exited, code=exited, status=203/EXEC

The logs don't show any error messages from the kubelet itself. Usually if the kubelet is started and exits because of an error, like an unknown argument passed, there will be error logs. But because there is nothing more here it could be a good idea to try to execute the kubelet binary manually.

We already did this above before checking the logs and it showed us that a wrong binary path was used in the service config file.

 

###### **Fix the Kubelet**

We go ahead and correct the path in file /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf:

\# cka1024:/usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf

\# Note: This dropin only works with kubeadm and kubelet v1.11+

\[Service\]

Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"

Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"

\# This is a file that "kubeadm init" and "kubeadm join" generates at runtime, populating the KUBELET_KUBEADM_ARGS variable dynamically

EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env

\# This is a file that the user can use for overrides of the kubelet args as a last resort. Preferably, the user should use

\# the .NodeRegistration.KubeletExtraArgs object in the configuration files instead. KUBELET_EXTRA_ARGS should be sourced from this file.

EnvironmentFile=-/etc/default/kubelet

ExecStart=

ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS

In the very last line we updated the binary path to /usr/bin/kubelet.

Now we reload the service:

● kubelet.service - kubelet: The Kubernetes Node Agent

    Loaded: loaded (/usr/lib/systemd/system/kubelet.service; enabled; preset: enabled)

   Drop-In: /usr/lib/systemd/system/kubelet.service.d

            └─10-kubeadm.conf

    Active: active (running) since Wed 2025-04-23 12:33:25 UTC; 5s ago

      Docs: https://kubernetes.io/docs/

  Main PID: 13124 (kubelet)

     Tasks: 9 (limit: 1317\)

    Memory: 88.3M (peak: 88.6M)

       CPU: 1.093s

    CGroup: /system.slice/kubelet.service

            └─13124 /usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/ku\>

...

root       13124  9.2  7.1 1896084 82432 ?       Ssl  12:33   0:01 /usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --config=/var/lib/kubelet/config.yaml --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock --pod-infra-container-image=registry.k8s.io/pause:3.10

...

That looks much better. We can wait for the containers to appear, which can take a minute:

CONTAINER      ...  CREATED           STATE       NAME                      ...

ccfbd17742b05  ...  25 seconds ago    Running     kube-controller-manager   ...

ff3910e3c8c6c  ...  25 seconds ago    Running     kube-scheduler            ...

9b49473786774  ...  25 seconds ago    Running     kube-apiserver            ...

f5de1f6e11d5c  ...  26 seconds ago    Running     etcd                      ...

ℹ️ In this environment crictl can be used for container management. In t
EOF
