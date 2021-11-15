
## Kubectl describe

Descreve informações detalhadas sobre nodes, pods, serviços, basicamente todo o conteudo do k8s 

https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#describe


Sintaxe
```
$ kubectl describe (-f FILENAME | TYPE [NAME_PREFIX | -l label] | TYPE/NAME)
```

```bash
Examples:
  # Describe a node
  kubectl describe nodes kubernetes-node-emt8.c.myproject.internal
  
  # Describe a pod
  kubectl describe pods/nginx
  
  # Describe a pod identified by type and name in "pod.json"
  kubectl describe -f pod.json
  
  # Describe all pods
  kubectl describe pods
  
  # Describe pods by label name=myLabel
  kubectl describe po -l name=myLabel
  
  # Describe all pods managed by the 'frontend' replication controller (rc-created pods
  # get the name of the rc as a prefix in the pod the name)
  kubectl describe pods frontend


  # Get ip from node
  kubectl describe node kube-control-panel | grep InternalIP
```
