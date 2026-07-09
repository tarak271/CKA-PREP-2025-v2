#!/bin/bash
cat <<'EOF'
Solution notes — Question 13 | Gateway Api Ingress

Comparing for example the older *Ingress* (networking.k8s.io/v1) and newer *HTTPRoute* (gateway.networking.k8s.io/v1) *CRDs* then they look quite similar in what they offer. They have a different config structure but provide the same idea of functionality.

The magic of the Gateway Api comes more to shine because of further resources (*GRPCRoute*, *TCPRoute*) and the architecture which is designed to be more flexible and extendable. This will provide better integration into existing cloud infrastructure and providers like GCP or AWS will be able to develop their own Gateway Api implementations.

 

###### **Investigate CRDs**

It was mentioned that a *Gateway* already exists, let's verify this:

NAME                                        CREATED AT

clientsettingspolicies.gateway.nginx.org    2024-12-28T13:11:21Z

gatewayclasses.gateway.networking.k8s.io    2024-12-28T13:11:21Z

gateways.gateway.networking.k8s.io          2024-12-28T13:11:21Z

grpcroutes.gateway.networking.k8s.io        2024-12-28T13:11:21Z

httproutes.gateway.networking.k8s.io        2024-12-28T13:11:22Z

nginxgateways.gateway.nginx.org             2024-12-28T13:11:23Z

nginxproxies.gateway.nginx.org              2024-12-28T13:11:23Z

observabilitypolicies.gateway.nginx.org     2024-12-28T13:11:23Z

referencegrants.gateway.networking.k8s.io   2024-12-28T13:11:23Z

snippetsfilters.gateway.nginx.org           2024-12-28T13:11:23Z

NAMESPACE      NAME   CLASS   ADDRESS   PROGRAMMED   AGE

project-r500   main   nginx             True         2m

NAME    CONTROLLER                                   ACCEPTED   AGE

nginx   gateway.nginx.org/nginx-gateway-controller   True       2m12s

We can see that various *CRDs* from gateway.networking.k8s.io are available. In this scenario we'll only work directly with *HTTPRoute* which we need to create. It will reference the existing *Gateway* main which references the existing *GatewayClass* nginx:

apiVersion: gateway.networking.k8s.io/v1

kind: Gateway

metadata:

...

 name: main

 namespace: project-r500

spec:

 gatewayClassName: nginx

 listeners:

 - allowedRoutes:

     namespaces:

       from: Same

   name: http

   port: 80

   protocol: HTTP

...

 

###### **Investigate URL reachability**

We can already contact the *Gateway* like this:

\<html\>

\<head\>\<title\>404 Not Found\</title\>\</head\>

\<body\>

\<center\>\<h1\>404 Not Found\</h1\>\</center\>

\<hr\>\<center\>nginx\</center\>

\</body\>

\</html\>

We receive a 404 because no routes have been defined yet. We receive this 404 from a Nginx because the Gateway Api implementation in this scenario has been done via the Nginx Gateway Fabric. But for this scenario it wouldn't matter if another implementation (Traefik, Envoy, ...) would've been used, because all will work with the same Gateway Api *CRDs*.

The url r500.gateway:30080 is reachable because of a static entry in /etc/hosts which points to the only node in the cluster. And on that node, as well as on all others if there would be more, port 30080 is open because of a NodePort *Service*:

NAME            TYPE       CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE

nginx-gateway   NodePort   10.103.36.0   \<none\>        80:30080/TCP   58m

 

###### **Step 1**

Now we'll have a look at the provided *Ingress* Yaml which we need to convert:

\# cka7968:/opt/course/13/ingress.yaml

apiVersion: networking.k8s.io/v1

kind: Ingress

metadata:

 name: traffic-director

spec:

 ingressClassName: nginx

 rules:

   - host: r500.gateway

     http:

       paths:

         - backend:

             service:

               name: web-desktop

               port:

                 number: 80

           path: /desktop

           pathType: Prefix

         - backend:

             service:

               name: web-mobile

               port:

                 number: 80

           path: /mobile

           pathType: Prefix

We can see two paths /desktop and /mobile which point to the K8s *Services* web-desktop and web-mobile. Based on this we create a *HTTPRoute* which replicates the behaviour and in which we reference the existing *Gateway*:

apiVersion: gateway.networking.k8s.io/v1

kind: HTTPRoute

metadata:

 name: traffic-director

 namespace: project-r500

spec:

 parentRefs:

   - name: main   \# use the name of the existing Gateway

 hostnames:

   - "r500.gateway"

 rules:

   - matches:

       - path:

           type: PathPrefix

           value: /desktop

     backendRefs:

       - name: web-desktop

         port: 80

   - matches:

       - path:

           type: PathPrefix

           value: /mobile

     backendRefs:

       - name: web-mobile

         port: 80

After creation we can test:

NAME               HOSTNAMES       AGE

traffic-director   \["r500.gateway"\]   7s

Web Desktop App

Web Mobile App

\<html\>

\<head\>\<title\>404 Not Found\</title\>\</head\>

\<body\>

\<center\>\<h1\>404 Not Found\</h1\>\</center\>

\<hr\>\<center\>nginx\</center\>

\</body\>

\</html\>

This looks like what we want\!

 

###### **Step 2**

Now things get more interesting and we need to add new path /auto which redirects depending on the User-Agent. The User-Agent is handled as a HTTP header and we only have to check for the exact value, hence we can extend our *HTTPRoute* like this:

apiVersion: gateway.networking.k8s.io/v1

kind: HTTPRoute

metadata:

 name: traffic-director

 namespace: project-r500

spec:

 parentRefs:

   - name: main

 hostnames:

   - "r500.gateway"

 rules:

   - matches:

       - path:

           type: PathPrefix

           value: /desktop

     backendRefs:

       - name: web-desktop

         port: 80

   - matches:

       - path:

           type: PathPrefix

           value: /mobile

     backendRefs:

       - name: web-mobile

         port: 80

\# NEW FROM HERE ON

   - matches:

       - path:

           type: PathPrefix

           value: /auto

         headers:

         - type: Exact

           name: user-agent

           value: mobile

     backendRefs:

       - name: web-mobile

         port: 80

   - matches:

       - path:

           type: PathPrefix

           value: /auto

     backendRefs:

       - name: web-desktop

         port: 80

We added two new rules, the first redirects to mobile conditionally on header value and the second redirects to desktop.

If the question text mentions something like "add one new path /auth" then this doesn't necessarily mean just one entry in the rules array, it can depend on conditions. We added at first the following rule:

   - matches:

       - path:

           type: PathPrefix

           value: /auto

         headers:

         - type: Exact

           name: user-agent

           value: mobile

     backendRefs:

       - name: web-mobile

         port: 80

Note that we use - path: and header:, not - path: and - header:. This means both path and header will be connected **AND**. So only if the path is /auto **AND** the header user-agent is mobile we route to mobile.

If we would do the following then these would be connected **OR** and it would be wrong for this question:

\# WRONG EXAMPLE for explanation

   - matches:

       - path:

           type: PathPrefix

           value: /auto

       - headers:            \# WRONG because now path and header are connected OR

         - type: Exact

           name: user-agent

           value: mobile

     backendRefs:

       - name: web-mobile

         port: 80

The next rule we added is the one for desktop, at the very end:

   - matches:

       - path:

           type: PathPrefix

           value: /auto

     backendRefs:

       - name: web-desktop

         port: 80

In this one we don't have to check any header value again because the question required that "otherwise" traffic should be redirected to desktop. So this acts as a "catch all" for route /auto.

We need to understand that the order of rules matters. If we would add the desktop rule before the mo
EOF
