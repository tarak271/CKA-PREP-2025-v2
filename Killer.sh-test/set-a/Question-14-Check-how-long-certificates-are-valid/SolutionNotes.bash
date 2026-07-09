#!/bin/bash
cat <<'EOF'
Solution notes — Question 14 | Check how long certificates are valid

First let's find that certificate:

/etc/kubernetes/pki/apiserver-etcd-client.key

/etc/kubernetes/pki/apiserver-kubelet-client.key

/etc/kubernetes/pki/apiserver-etcd-client.crt

/etc/kubernetes/pki/apiserver.key

/etc/kubernetes/pki/apiserver-kubelet-client.crt

/etc/kubernetes/pki/apiserver.crt

Next we use openssl to find out the expiration date:

       Validity

           Not Before: Oct 29 14:14:27 2024 GMT

           Not After : Oct 29 14:19:27 2025 GMT

There we have it, so we write it in the required location:

\# cka9412:/opt/course/14/expiration

Oct 29 14:19:27 2025 GMT

And we use kubeadm to get the expiration to compare:

apiserver                  Oct 29, 2025 14:19 UTC   356d    ca         no      

apiserver-etcd-client      Oct 29, 2025 14:19 UTC   356d    etcd-ca    no      

apiserver-kubelet-client   Oct 29, 2025 14:19 UTC   356d    ca         no

Looking good, both are the same.

And finally we write the command that would renew the kube-apiserver certificate into the requested location:

\# cka9412:/opt/course/14/kubeadm-renew-certs.sh

kubeadm certs renew apiserver
EOF
