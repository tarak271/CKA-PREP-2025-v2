#!/bin/bash
cat <<'EOF'
Solution notes — Question 3 | Kubelet client/server cert info

First we check the kubelet client certificate:

/var/lib/kubelet/pki

/var/lib/kubelet/pki/kubelet-client-2024-10-29-14-24-14.pem

/var/lib/kubelet/pki/kubelet.crt

/var/lib/kubelet/pki/kubelet.key

/var/lib/kubelet/pki/kubelet-client-current.pem

       Issuer: CN \= kubernetes

       

           X509v3 Extended Key Usage:

               TLS Web Client Authentication

Next we check the kubelet server certificate:

       Issuer: CN \= cka5248-node1-ca@1730211854

           X509v3 Extended Key Usage:

               TLS Web Server Authentication

We see that the server certificate was generated on the worker node itself and the client certificate was issued by the Kubernetes api. The Extended Key Usage also shows if it's for client or server authentication.

The solution file should look something like this:

\# cka5248:/opt/course/3/certificate-info.txt

Issuer: CN \= kubernetes

X509v3 Extended Key Usage: TLS Web Client Authentication

Issuer: CN \= cka5248-node1-ca@1730211854

X509v3 Extended Key Usage: TLS Web Server Authentication
EOF
