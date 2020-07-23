#Kubernetes

# It is a container orchestrator tool that allow us to manage and scale containers easily

############################### building Kubernetes cluster ##################

# simple cluster consists of 3 node:
 ------			 --------        --------
|Master|		|Kub Node|		|Kub Node|
 ------			 --------        --------
 Docker			  Docker 	       Docker     # Container Engine
 Kubeadm          Kubeadm          Kubeadm    # Simplify cluster creation
 Kubelet          Kubelet          Kubelet    # An agent to manage the cluster
 Kubectl          Kubectl          Kubectl	  # Kubernetes command line
 Control 		                              # Controller for the Master Node
 ================================================================


