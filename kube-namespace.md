## Namespaces


https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/


No Kubernetes, os namespaces fornecem um mecanismo para isolar grupos de recursos em um único cluster. Os nomes dos recursos precisam ser exclusivos em um namespace, mas não entre os namespaces. O escopo baseado em namespace é aplicável apenas para objetos com namespace (por exemplo, implantações, serviços, etc) e não para objetos de todo o cluster (por exemplo, StorageClass, Nodes, PersistentVolumes, etc) .



```bash
kubectl get namespace

NAME              STATUS   AGE
default           Active   1d
kube-node-lease   Active   1d
kube-public       Active   1d
kube-system       Active   1d


```

O Kubernetes começa com quatro namespaces iniciais:

- **default** O namespace padrão para objetos sem outro namespace
- **kube-system** O namespace para objetos criados pelo sistema Kubernetes
- **kube-public** Este namespace é criado automaticamente e pode ser lido por todos os usuários (incluindo aqueles não autenticados). Este namespace é principalmente reservado para uso do cluster, no caso de alguns recursos ficarem visíveis e legíveis publicamente em todo o cluster. O aspecto público deste namespace é apenas uma convenção, não um requisito.
- **kube-node-lease** Este namespace contém objetos Lease associados a cada nó. As concessões de nó permitem que o kubelet envie pulsações para que o plano de controle possa detectar a falha do nó.


## Definir a preferência de namespace
Você pode salvar permanentemente o namespace para todos os comandos kubectl subsequentes nesse contexto.

```bash
kubectl run nginx --image=nginx --namespace=<insert-namespace-name-here>
kubectl get pods --namespace=<insert-namespace-name-here>
```

## Criar um namespace

Via yaml
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: <insert-namespace-name-here>
```

```
kubectl create -f ./my-namespace.yaml
```

Via cli

```bash
kubectl create namespace <insert-namespace-name-here>
```

## Para excluir um NS

```bash
kubectl delete namespaces <insert-some-namespace-name>
```

Exemplo de namespace com labels

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: <insert-namespace-name-here>
  labels: develop
```

```bash
kubectl get namespaces --show-labels

NAME          STATUS    AGE       LABELS
default       Active    32m       <none>
development   Active    29s       name=development
production    Active    23s       name=production


# lista todos os pods em todos os namespaces
kubectl get pods --all-namespaces

# lista todos os pods em todos os namespaces no formato wide
kubectl get pods --all-namespaces -o wide

```


## Capturando o yaml de um pod

```
kubectl get pods nginx -o yaml
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: "2021-11-09T02:14:47Z"
  labels:
    run: nginx
  name: nginx
  namespace: default
  resourceVersion: "8242734"
  uid: a8abfd0a-737f-471e-b33a-fab33ced8f8c
spec:
  containers:
  - image: nginx
    imagePullPolicy: Always
    name: nginx
    resources: {}
    terminationMessagePath: /dev/termination-log
    terminationMessagePolicy: File
    volumeMounts:
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: kube-api-access-dnq6r
      readOnly: true
  ...
  ...

```


