# Primeiros passos - Versão 1.19.3


## Conceitos-chave do k8s
É importante saber que a forma como o k8s gerencia os contêineres é ligeiramente diferente de outros orquestradores, como o Docker Swarm, sobretudo devido ao fato de que ele não trata os contêineres diretamente, mas sim através de pods. Vamos conhecer alguns dos principais conceitos que envolvem o k8s a seguir:

**Pod:** é o menor objeto do k8s. Como dito anteriormente, o k8s não trabalha com os contêineres diretamente, mas organiza-os dentro de pods, que são abstrações que dividem os mesmos recursos, como endereços, volumes, ciclos de CPU e memória. Um pod, embora não seja comum, pode possuir vários contêineres;

**Controller:** é o objeto responsável por interagir com o API Server e orquestrar algum outro objeto. Exemplos de objetos desta classe são os Deployments e Replication Controllers;

**ReplicaSets:** é um objeto responsável por garantir a quantidade de pods em execução no nó;

**Deployment:** É um dos principais controllers utilizados. O Deployment, em conjunto com o ReplicaSet, garante que determinado número de réplicas de um pod esteja em execução nos nós workers do cluster. Além disso, o Deployment também é responsável por gerenciar o ciclo de vida das aplicações, onde características associadas a aplicação, tais como imagem, porta, volumes e variáveis de ambiente, podem ser especificados em arquivos do tipo yaml ou json para posteriormente serem passados como parâmetro para o kubectl executar o deployment. Esta ação pode ser executada tanto para criação quanto para atualização e remoção do deployment;

**Jobs e CronJobs:** são objetos responsáveis pelo gerenciamento de jobs isolados ou recorrentes.

## Kubectl describe

Descreve informações sobre nodes, pods, serviços, basicamente todo o conteudo do k8s vc pode usaro describe

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



## Tants 
    Baiscamente conseguimos colocar restrições em um nó
    https://kubernetes.io/pt-br/docs/concepts/scheduling-eviction/taint-and-toleration/

Exemplo:

Você adiciona um taint a um nó utilizando kubectl taint. Por exemplo,

```
kubectl taint nodes node1 key1=value1:NoSchedule
```

define um taint no nó node1. O taint tem a chave key1, valor value1 e o efeito NoSchedule. Isso significa que nenhum pod conseguirá ser executado no nó node1 a menos que possua uma tolerância correspondente.


## Como recuperar o Token para adicionar mais nós?

```
kubeadm token create --print-join-command 
``` 

## Como adicionar o completion?

```bash
kubectl completion bash > /etc/bash_completion.d/kubectl

# BASH
source <(kubectl completion bash) # configura o autocomplete na sua sessão atual (antes, certifique-se de ter instalado o pacote bash-completion).

echo "source <(kubectl completion bash)" >> ~/.bashrc # add autocomplete permanentemente ao seu shell.

#ZSH
source <(kubectl completion zsh)

echo "[[ $commands[kubectl] ]] && source <(kubectl completion zsh)"
``` 

## kubectl get pods --all-namespaces

O valor da coluna ready é a quantidade de containers que estão rodando dentro de um pod
```bash

NAMESPACE      NAME                                               READY   STATUS    RESTARTS   AGE
...
...
prometheus     prometheus-server-74ccdfcc-hr6wd                   2/2     Running   0          5d8h
                                                                   ^
```

### Describe do pod
```
kubectl describe pod -n prometheus prometheus-server-74ccdfcc-hr6wd
```

```yaml
Name:         prometheus-server-74ccdfcc-hr6wd
Namespace:    prometheus
Priority:     0
Node:         ip-172-30-3-239.ec2.internal/172.30.3.239
Start Time:   Wed, 03 Nov 2021 14:16:27 -0300
Labels:       app=prometheus
              chart=prometheus-14.11.0
              component=server
              heritage=Helm
              pod-template-hash=74ccdfcc
              release=prometheus
Annotations:  kubernetes.io/psp: eks.privileged
Status:       Running
IP:           xxx
IPs:
  IP:           xxx
Controlled By:  ReplicaSet/prometheus-server-74ccdfcc
Containers:

  # Container 1
  prometheus-server-configmap-reload:
    Container ID:  docker://0cec7e886f5d9c43cf7334abe2088510a34edf4f5adb44f25cdfa4dab808e8f9
    Image:         jimmidyson/configmap-reload:v0.5.0
    Image ID:      docker-pullable://jimmidyson/configmap-reload@sha256:904d08e9f701d3d8178cb61651dbe8edc5d08dd5895b56bdcac9e5805ea82b52
    Port:          <none>
    Host Port:     <none>
    Args:
      --volume-dir=/etc/config
      --webhook-url=http://127.0.0.1:9090/-/reload
    State:          Running
      Started:      Wed, 03 Nov 2021 14:16:38 -0300
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /etc/config from config-volume (ro)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-ggzkm (ro)
  
  # Container 2
  prometheus-server:
    Container ID:  docker://edff694527f9ec2542af2e6f2fdf8273b45704a63c19ef6ef534decf58a66cd3
    Image:         quay.io/prometheus/prometheus:v2.26.0
    Image ID:      docker-pullable://quay.io/prometheus/prometheus@sha256:38d40a760569b1c5aec4a36e8a7f11e86299e9191b9233672a5d41296d8fa74e
    Port:          9090/TCP
    Host Port:     0/TCP
    Args:
      --storage.tsdb.retention.time=15d
      --config.file=/etc/config/prometheus.yml
      --storage.tsdb.path=/data
      --web.console.libraries=/etc/prometheus/console_libraries
      --web.console.templates=/etc/prometheus/consoles
      --web.enable-lifecycle
    State:          Running
      Started:      Wed, 03 Nov 2021 14:16:42 -0300
    Ready:          True
    Restart Count:  0
    Liveness:       http-get http://:9090/-/healthy delay=30s timeout=10s period=15s #success=1 #failure=3
    Readiness:      http-get http://:9090/-/ready delay=30s timeout=4s period=5s #success=1 #failure=3
    Environment:    <none>
    Mounts:
      /data from storage-volume (rw)
      /etc/config from config-volume (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-ggzkm (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  config-volume:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      prometheus-server
    Optional:  false
  storage-volume:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  prometheus-server
    ReadOnly:   false
  kube-api-access-ggzkm:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:                      <none>

```

## Pegando mais informações na saída de um comando

```
kubectl get pods --all-namespaces -o wide

NAMESPACE     NAME                                         READY   STATUS    RESTARTS        AGE   IP              NODE                 NOMINATED NODE   READINESS GATES
default       nginx                                        1/1     Running   5 (4d9h ago)    83d   10.244.0.18     kube-control-panel   <none>           <none>

```

## Namespaces

https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/

In Kubernetes, namespaces provides a mechanism for isolating groups of resources within a single cluster. Names of resources need to be unique within a namespace, but not across namespaces. Namespace-based scoping is applicable only for namespaced objects (e.g. Deployments, Services, etc) and not for cluster-wide objects (e.g. StorageClass, Nodes, PersistentVolumes, etc).

```
kubectl get namespace

kubectl create namespace teste01

kubectl delete namespace teste01

```

## Eventos

```
kubectl run nginx --image=nginx
kubectl describe pod nginx

...
...
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  21s   default-scheduler  Successfully assigned default/nginx to kube-control-panel
  Normal  Pulling    19s   kubelet            Pulling image "nginx"
  Normal  Pulled     17s   kubelet            Successfully pulled image "nginx" in 2.15185333s
  Normal  Created    17s   kubelet            Created container nginx
  Normal  Started    17s   kubelet            Started container nginx

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
  dnsPolicy: ClusterFirst
  enableServiceLinks: true
  nodeName: kube-control-panel
  preemptionPolicy: PreemptLowerPriority
  priority: 0
  restartPolicy: Always
  schedulerName: default-scheduler
  securityContext: {}
  serviceAccount: default
  serviceAccountName: default
  terminationGracePeriodSeconds: 30
  tolerations:
  - effect: NoExecute
    key: node.kubernetes.io/not-ready
    operator: Exists
    tolerationSeconds: 300
  - effect: NoExecute
    key: node.kubernetes.io/unreachable
    operator: Exists
    tolerationSeconds: 300
  volumes:
  - name: kube-api-access-dnq6r
    projected:
      defaultMode: 420
      sources:
      - serviceAccountToken:
          expirationSeconds: 3607
          path: token
      - configMap:
          items:
          - key: ca.crt
            path: ca.crt
          name: kube-root-ca.crt
      - downwardAPI:
          items:
          - fieldRef:
              apiVersion: v1
              fieldPath: metadata.namespace
            path: namespace
status:
  conditions:
  - lastProbeTime: null
    lastTransitionTime: "2021-11-09T02:14:47Z"
    status: "True"
    type: Initialized
  - lastProbeTime: null
    lastTransitionTime: "2021-11-09T02:14:52Z"
    status: "True"
    type: Ready
  - lastProbeTime: null
    lastTransitionTime: "2021-11-09T02:14:52Z"
    status: "True"
    type: ContainersReady
  - lastProbeTime: null
    lastTransitionTime: "2021-11-09T02:14:47Z"
    status: "True"
    type: PodScheduled
  containerStatuses:
  - containerID: docker://f12316285da0b78645ec933078fb25ad632908ee8ebb51bb4f6b0ac4726386b4
    image: nginx:latest
    imageID: docker-pullable://nginx@sha256:644a70516a26004c97d0d85c7fe1d0c3a67ea8ab7ddf4aff193d9f301670cf36
    lastState: {}
    name: nginx
    ready: true
    restartCount: 0
    started: true
    state:
      running:
        startedAt: "2021-11-09T02:14:51Z"
  hostIP: 192.168.1.211
  phase: Running
  podIP: 10.244.0.21
  podIPs:
  - ip: 10.244.0.21
  qosClass: BestEffort
  startTime: "2021-11-09T02:14:47Z"

```

## Criando primeiro pod via yaml

Arquivos na pasta templates

```bash
kubectl create -f meu-primeiro.yaml
kubectl delete -f meu-primeiro.yaml

# Para gerar o arquivo yaml
kubectl run nginx --image=nginx --dry-run=client -o yaml > meu_segundo_pod.yaml
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}

```

## Primeiros passos - Versão 1.19.3 - Parte 2
---

## Exponto um pod

```
kubectl expose pod nginx

NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
nginx        ClusterIP   10.96.56.238   <none>        80/TCP    40s
```
O tipo ClusterIP só funciona internamente no cluster

Descrição de como está configurado o serviço do NGINX que foi exposto
```
kubectl describe service nginx
Name:              nginx
Namespace:         default
Labels:            run=nginx
Annotations:       <none>
Selector:          run=nginx
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                10.96.56.238
IPs:               10.96.56.238
Port:              <unset>  80/TCP
TargetPort:        80/TCP
Endpoints:         10.244.0.24:80
Session Affinity:  None
Events:            <none>
```

## Como acessar os manuais pela linha de comando
```
kubectl explain pod
```






