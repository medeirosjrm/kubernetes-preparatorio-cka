## Limits


### Container restart policy

https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#restart-policy

### Container hooks

https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/

```yaml
resources:
    limits: # é o total que o k8s vai liberar
        memory: "512Mi" #memória em MB
        cpu: "500m" #metade de um core
    requests: # é o quando o k8s vai garantir
        memory: "128Mi" # 128mb garantidos pelo k8s
        cpu: "250m" # 1/4 de processador
```


## Limit Ranges

https://kubernetes.io/docs/concepts/policy/limit-range/

By default, containers run with unbounded compute resources on a Kubernetes cluster. With resource quotas, cluster administrators can restrict resource consumption and creation on a namespace basis. Within a namespace, a Pod or Container can consume as much CPU and memory as defined by the namespace's resource quota. There is a concern that one Pod or Container could monopolize all available resources. A LimitRange is a policy to constrain resource allocations (to Pods or Containers) in a namespace.

A LimitRange provides constraints that can:

- Enforce minimum and maximum compute resources usage per Pod or Container in a namespace.
- Enforce minimum and maximum storage request per PersistentVolumeClaim in a namespace.
- Enforce a ratio between request and limit for a resource in a namespace.
- Set default request/limit for compute resources in a namespace and automatically inject them to Containers at runtime.


Resumo: aplica regras de limites para todos os pods que fazem parte desse namespace
```
kubectl create -f limite-range-template.yaml -n namespace
```

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: limitando-recursos
spec:
  limits:
  - default: # = limit do pod
      cpu: 1
      memory: 100Mi
    defaultRequest: # = ao request do pod
      cpu: 0.5
      memory: 80Mi
    type: Container
```