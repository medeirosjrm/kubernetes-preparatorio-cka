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
https://kubernetes.io/pt-br/docs/concepts/storage/persistent-volumes/#persistentvolumes-do-tipo-hostpath
https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/#create-a-persistentvolume


Nesse exercício vamos configurar um PersistentVolume com HostPath e para isso é necessário fazer alguns passo.

- Vamos precisar de um cluster com apenas um nó, támbem é possível fazer esse processo adicionado a Taint de NoSchedule nos outro nós ou utilizar o Minikube

>Ps. No meu caso eu tenho um control plane e dois workers então vou adicionar a Taint NoSchedule em um dos nós.

### Passo 1: Adicionar o NoSchedule em um dos nós.

```bash
kubectl taint nodes kube-w2 key1=value1:NoSchedule
kubectl describe nodes kube-w2

```

### Passo 2: Acessar o nó que ainda está recebendo pods e criar o arquivo index.html 


```bash
ssh kube-w1 
sudo mkdir /mnt/data
sudo sh -c "echo 'Hello from Kubernetes storage' > /mnt/data/index.html"
cat /mnt/data/index.html
```

### Passo 3: Voltar para o control plane ou para o terminal onde está rodando o seu kubectl para criar um PersistentVolume e um PersistentVolumeClaim

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: task-pv-volume
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data"

```

```bash
kubectl create -f pv-volume.yaml
kubectl get pv task-pv-volume
```

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: task-pv-claim
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Mi

```
```bash
kubectl create -f pv-claim.yaml
kubectl get pv task-pv-volume
kubectl get pvc task-pv-claim
```

### Passo 4: Criar o pod que vai usar esse volume

```bash
kubectl run task-pv-pod --image nginx --port 80 --dry-run=client -o yaml > pv-pod.yaml
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: task-pv-pod
  name: task-pv-pod
spec:
  volumes:
    - name: task-pv-storage
      persistentVolumeClaim:
          claimName: task-pv-claim
  containers:
  - image: nginx
    name: task-pv-pod
    ports:
    - containerPort: 80
    volumeMounts:
      - mountPath: "/usr/share/nginx/html"
        name: task-pv-storage
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}


```

Vamos verificar se o volume foi criado corretamente dentro do pod

```bash
kubectl exec -ti task-pv-pod -- /bin/bash

curl http://localhost
Hello from Kubernetes storage

#Ou

cat /usr/share/nginx/html/index.html
Hello from Kubernetes storage

```

### Passo 5: Limpando tudo

```bash
kubectl delete pod task-pv-pod
kubectl delete pvc task-pv-claim
kubectl delete pv task-pv-volume

# Acessar o node via ssh e limpar a pasta

ssh kube-w1
sudo rm -rf /mnt/data

# Remover a Taint
kubectl taint node kube-w2 key1:NoSchedule-
kubectl describe node kube-w2
```




## 5 - Criar um initcontainer para executar uma tarefa necessária para a subida do container principal.

https://kubernetes.io/docs/concepts/workloads/pods/init-containers/#init-containers-in-use

> Esse tutorial funciona.
https://docs.openshift.com/container-platform/4.8/nodes/containers/nodes-containers-init.html

Vamos subir um pod a nossa aplicação que será um busybox, antes de rodar propriamente a nossa aplicação fake, vamos subir dois initContainer que vão ser um serviço (fake) e um banco de dados (fake) simulando um cenário que precisamos de duas inicializações antes da aplicação estar pronta para uso.


```bash
kubectl run myapp-pod --image busybox --dry-run=client -o yaml > myapp-pod.yaml
```

Vamos editar nosso yaml e adicionar os initContainers

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: myapp-pod
  name: myapp-pod
spec:
  containers:
  - image: busybox
    name: myapp-container
    command: ['sh', '-c', 'echo The app is running! && sleep 3600']
  initContainers:
  - name: init-myservice
    image: busybox
    command: ['sh','-c', 'until nslookup myservice.default.svc.cluster.local; do echo waiting for myservice; sleep 2; done']
  - name: init-mydb
    image: busybox
    command: ['sh','-c', 'until nslookup mydb.default.svc.cluster.local; do echo waiting for mydb; sleep 2; done']
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```

Verificando o status do pod
```bash
kubectl get -f myapp-pod.yaml
#ou
kubectl get pods myapp-pod

#vamos vefificar os detalhes do pod
kubectl describe pod myapp-pod
```

O que esperamos encontrar no describe?

- Queremos ver que o primeiro initContainer está running enquanto o segundo está waiting assim como o container da aplicação

```yaml
Name:          myapp-pod
Namespace:     default
[...]
Labels:        app=myapp
Status:        Pending
[...]
Init Containers:
  init-myservice:
[...]
    State:         Running
[...]
  init-mydb:
[...]
    State:         Waiting
      Reason:      PodInitializing
    Ready:         False
[...]
Containers:
  myapp-container:
[...]
    State:         Waiting
      Reason:      PodInitializing
    Ready:         False
[...]
Events:
  FirstSeen    LastSeen    Count    From                      SubObjectPath                           Type          Reason        Message
  ---------    --------    -----    ----                      -------------                           --------      ------        -------
  16s          16s         1        {default-scheduler }                                              Normal        Scheduled     Successfully assigned myapp-pod to 172.17.4.201
  16s          16s         1        {kubelet 172.17.4.201}    spec.initContainers{init-myservice}     Normal        Pulling       pulling image "busybox"
  13s          13s         1        {kubelet 172.17.4.201}    spec.initContainers{init-myservice}     Normal        Pulled        Successfully pulled image "busybox"
  13s          13s         1        {kubelet 172.17.4.201}    spec.initContainers{init-myservice}     Normal        Created       Created container with docker id 5ced34a04634; Security:[seccomp=unconfined]
  13s          13s         1        {kubelet 172.17.4.201}    spec.initContainers{init-myservice}     Normal        Started       Started container with docker id 5ced34a04634
```

Verificando os logs dos containers do pod
```
kubectl logs myapp-pod -c init-myservice
$ waiting for myservice
$ waiting for myservice

kubectl logs myapp-pod -c init-mydb
$ Error from server (BadRequest): container "init-mydb" in pod "myapp-pod" is waiting to start: PodInitializing

```

Agora vamos criar os serviços

```bash
#Criando o myservice
kubectl create service clusterip myservice --tcp=80:9376 --dry-run=client -o yaml > myservice.yaml
kubectl create -f myservice.yaml

#Revisando os logs
kubectl logs myapp-pod -c init-myservice
#---
$ waiting for myservice
$ 10.96.234.248   myservice.default.svc.cluster.local

#Criand o mydb
kubectl create service clusterip mydb --tcp=80:9377 -o yaml --dry-run=client > mydb.yaml
kubectl create -f mydb.yaml

#Revisando os logs
kubectl logs myapp-pod -c init-mydb
#---
$ waiting for mydb
$ 10.108.139.2    mydb.default.svc.cluster.local

#Conferindo se o pod foi inicializado
kubectl get pods
kubectl logs myapp-pod -c myapp-container
#---
$The app is running!

```

Agora limpando a bagunça

```bash
kubectl delete svc mydb
kubectl delete svc myservice
 kubectl delete -f myapp-pod.yaml
```



## 6 - Criar um daemonset.


https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/


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

