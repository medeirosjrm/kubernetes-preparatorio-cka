# Questões

## 1 - Criar um pod com um volume não persistente.

https://kubernetes.io/docs/tasks/configure-pod-container/configure-volume-storage/
https://kubernetes.io/docs/tasks/configure-pod-container/configure-volume-storage/#configure-a-volume-for-a-pod

```bash
kubectl run redis --image redis --port 80 --dry-run=client -o yaml > meu-pod.yaml
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: redis
  name: redis
spec:
  containers:
  - image: redis
    name: redis
    ports:
    - containerPort: 80
    resources: {}
    volumeMounts:
    - name: redis-storage
      mountPath: /data/redis
  volumes:
  - name: redis-storage
    emptyDir: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```

```bash
kubectl get pod redis
kubectl exec -it redis -- /bin/bash

---
root@redis:/data# cd /data/redis/
root@redis:/data/redis# echo Hello > test-file

root@redis:/data/redis# apt-get update
root@redis:/data/redis# apt-get install procps
root@redis:/data/redis# ps aux

---output---
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
redis          1  0.1  1.2  52828 11460 ?        Ssl  01:56   0:00 redis-server *:6379
root          22  0.0  0.3   4100  3284 pts/0    Ss   01:56   0:00 /bin/bash
root         359  0.0  0.3   6700  2828 pts/0    R+   01:58   0:00 ps aux

```

## 2 - Criar um service/ep apontando para um pod.

```bash
kubectl run web --image nginx --port 80 --dry-run=client -o yaml > pod.yaml
kubectl expose pod web --type=NodePort
kubectl get svc,ep  #para verificar se o serviço e o endpoint foram criados
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: web
  name: web
spec:
  containers:
  - image: nginx
    name: web
    ports:
    - containerPort: 80
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```


## 3 - Colocar um node para que não execute nenhum containers.

Procurar quais Taints estão atribuidas ao nó que não deve executar nenhum container
```bash
kubectl describe nodes kube-w1
# Taints:


#vamos criar um deployment e alterar a quantidade de replicas dele
kubectl run pod-taint --image nginx --dry-run=client -o yaml > pod-taint.yaml

```
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: nginx
  name: nginx
spec:
  replicas: 5
  selector:
    matchLabels:
      app: nginx
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx
        name: nginx
        resources: {}
status: {}
```

```bash
kubectl create -f taints.yaml

#é possível ver que os pods foram distribuidos entres os nós kube-w1 e kube-w2
kubectl get pods -o wide
nginx-85b98978db-7t68f   1/1     Running   0             17s     10.40.0.5   kube-w2   <none>           <none>
nginx-85b98978db-82j9h   1/1     Running   0             17s     10.32.0.7   kube-w1   <none>           <none>
nginx-85b98978db-db7px   1/1     Running   0             17s     10.40.0.6   kube-w2   <none>           <none>
nginx-85b98978db-r6psq   1/1     Running   0             17s     10.32.0.9   kube-w1   <none>           <none>
nginx-85b98978db-vkm9x   1/1     Running   0             17s     10.32.0.8   kube-w1   
<none>           <none>

# Agora vamos deletar o deploy aplicar a taint e criar novamente o deploy
kubectl delete -f taints.yaml
# Adicionar um taint
kubectl taint nodes kube-w1 key1=value1:NoSchedule

# Todos os pods foram criados no node kube-w2
kubectl create -f taints.yaml
kubectl get pods -o wide
nginx-85b98978db-2nmgp   1/1     Running   0             14s     10.40.0.5   kube-w2   <none>           <none>
nginx-85b98978db-crnm6   1/1     Running   0             14s     10.40.0.6   kube-w2   <none>           <none>
nginx-85b98978db-nqw5x   1/1     Running   0             14s     10.40.0.9   kube-w2   <none>           <none>
nginx-85b98978db-r7nct   1/1     Running   0             14s     10.40.0.8   kube-w2   <none>           <none>
nginx-85b98978db-wbtfj   1/1     Running   0             14s     10.40.0.7   kube-w2   <none>           <none>

# Para finalizar vou refazer o processo removendo a taint e recriando os pods

# Remover o taint
kubectl taint node kube-w1 key1:NoSchedule-

```

## 4 - Criar um PV Hostpath.

https://kubernetes.io/docs/concepts/storage/volumes/#hostpath
https://linuxroutes.com/how-to-create-hostpath-persistent-volume-kubernetes/

Exemplo:
https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/#create-a-persistentvolume



## 5 - Criar um initcontainer para executar uma tarefa necessária para a subida do container principal.

## 6 - Criar um daemonset.

## 7 - Criar um deployment do nginx com 5 réplicas.

## 8 - Ver quais os pods que mais estão consumindo cpu através do kubectl top.

## 9 - Organizar a saída do comando "kubectl get pods" pelo tamanho do capacity storage.

## 10 - Qual a quantidade de nodes que estão aceitando novos containers

## 11 - Criar um secret e dois pods, um montando o secret em filesystem e outro como variável

## 12 - Fazer a instalação do nginx em determinada versão, atualizar e depois realizar o rollback com o --record.

## 13 - EXTRA - Realizar o backup do etcd.

## 14 - Identificar quais pods fazem parte de determinado services.

## 15 - Usar o nslookup e/ou outras ferramentas para pegar o dns do pod e do service.

## 16 - Adicionar mais um node no cluster.

## 17 - Adicionar um label no node.

## 18 - Subir um pod com afinidade de node.

## 19 - Ajustar o nome de uma imagem com nome errado de um deployment

## 20 - Criar um cronjob.

## 21 - Criar Pod com o parametro containerport.

## 22 - Declarar a variável NGINX_PORT no env do container.

## 23 - Declarar a variável na configmap e passar para container.

## 24 - Declarar a variável no secret e passar para o container.

## 25 - Configurar resources limits no deployment.

## 26 - Configurar liveness e readiness no deployment.

## 27 - Criar um volume Emptydir e compartilhar entre 2 containers.

## 28 - Customizar o parâmetro command do container.

## 29 - Configurar um nodeselector para o Pod.

## 30 - Executar o kubectl rollback pause e resume.

## 31 - Utilizar o edit ou outro comando para corrigir o selector de um service para que ele funcione corretamente.

## 32 - Criar uma secret generic, outra from file e outra literal.

## 33 - Criar um configmap generic, outro from file e outro literal.

## 34 - Verifique a saúde de todos os nodes e seus componentes, como kubelet, proxy, api, controllers, schedullers, etc.

