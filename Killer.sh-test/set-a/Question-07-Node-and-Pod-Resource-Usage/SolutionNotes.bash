#!/bin/bash
cat <<'EOF'
Solution notes — Question 7 | Node and Pod Resource Usage

The command we need to use here is top:

Display resource (CPU/memory) usage.

The top command allows you to see the resource consumption for nodes or pods.

This command requires Metrics Server to be correctly configured and working on the server.

Available Commands:

 node          Display resource (CPU/memory) usage of nodes

 pod           Display resource (CPU/memory) usage of pods

Usage:

 kubectl top \[flags\] \[options\]

Use "kubectl top \<command\> --help" for more information about a given command.

Use "kubectl options" for a list of global command-line options (applies to all commands).

We see that the metrics server provides information about resource usage:

NAME            CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%  

cka5774         104m         10%    1121Mi          60%      

We create the first file, ensure to **not** use aliases but instead the full command names:

\# cka5774:/opt/course/7/node.sh

kubectl top node

For the second file we might need to check the docs again:

Display resource (CPU/memory) usage of pods.

...

   --containers=false:

       If present, print usage of containers within a pod.

...

With this we can finish this task:

\# cka5774:/opt/course/7/pod.sh

kubectl top pod --containers=true
EOF
