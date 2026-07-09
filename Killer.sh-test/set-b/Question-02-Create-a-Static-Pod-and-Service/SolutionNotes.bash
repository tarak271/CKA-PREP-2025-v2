#!/bin/bash
cat <<'EOF'
Solution notes — Question 2 | Create a Static Pod and Service

Then edit the my-static-pod.yaml to add the requested resource requests:

\# cka2560:/etc/kubernetes/manifests/my-static-pod.yaml

apiVersion: v1

kind: Pod

metadata:

 creationTimestamp: null

 labels:

   run: my-static-pod

 name: my-static-pod

spec:

 containers:

 - image: nginx:1-alpine

   name: my-static-pod

   resources:

     requests:

       cpu: 10m

       memory: 20Mi

 dnsPolicy: ClusterFirst

 restartPolicy: Always

status: {}

And make sure it's running:

default       my-static-pod-cka2560             1/1     Running   0            20s

Now we expose that static *Pod*:

This will generate a *Service* yaml like:

\# kubectl expose pod my-static-pod-cka2560 --name static-pod-service --type=NodePort --port 80

apiVersion: v1

kind: Service

metadata:

 creationTimestamp: null

 labels:

   run: my-static-pod

 name: static-pod-service

spec:

 ports:

 - port: 80

   protocol: TCP

   targetPort: 80

 selector:

   run: my-static-pod

 type: NodePort

status:

 loadBalancer: {}

Then we check the *Service* and *Endpoints*:

NAME                         TYPE       CLUSTER-IP      ...   PORT(S)        AGE

service/static-pod-service   NodePort   10.98.249.240   ...   80:32699/TCP   34s

NAME                       ADDRESSTYPE   PORTS   ENDPOINTS   AGE

static-pod-service-2h7cf   IPv4          80      10.32.0.4   34s

Also we should be able to access that Nginx container, your NodePort might be different than the one used here:

NAME            STATUS   ROLES           AGE   VERSION   INTERNAL-IP      ...

cka2560         Ready    control-plane   8d    v1.33.1   192.168.100.31   ...

\<\!DOCTYPE html\>

\<html\>

\<head\>

\<title\>Welcome to nginx\!\</title\>

\<style\>

html { color-scheme: light dark; }

body { width: 35em; margin: 0 auto;

font-family: Tahoma, Verdana, Arial, sans-serif; }

\</style\>

\</head\>

\<body\>

\<h1\>Welcome to nginx\!\</h1\>

\<p\>If you see this page, the nginx web server is successfully installed and

working. Further configuration is required.\</p\>

\<p\>For online documentation and support please refer to

\<a href="http://nginx.org/"\>nginx.org\</a\>.\<br/\>

Commercial support is available at

\<a href="http://nginx.com/"\>nginx.com\</a\>.\</p\>

\<p\>\<em\>Thank you for using nginx.\</em\>\</p\>

\</body\>

\</html\>
EOF
