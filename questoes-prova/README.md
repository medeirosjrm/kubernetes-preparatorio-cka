# Questões CKA


## Documentações:

Certified Kubernetes Application Developer (CKAD)
https://www.cncf.io/certification/ckad/

Simulado
https://www.katacoda.com/ckad-prep/scenarios/first-steps
https://killer.sh/


Tasks
https://kubernetes.io/docs/tasks/

Exercises
https://github.com/dgkanatsios/CKAD-exercises



## Autocomplete
https://kubernetes.io/docs/reference/kubectl/cheatsheet/

```bash
source <(kubectl completion bash) # setup autocomplete in bash into the current shell, bash-completion package should be installed first.
echo "source <(kubectl completion bash)" >> ~/.bashrc # add autocomplete permanently to your bash shell.
```




## Day 01

<br>

### Questão 1
Criar um pod utilizando a imagem do Nginx 1.18.0, com o nome de giropops no namespace strigus.

  
<b>Resposta 1</b>

Opção 1
```bash
# validar se o ns existe
kubectl get ns

# caso não exista
kubectl create ns strigus

#Executar o pod
kubectl run giropops --image nginx:1.18.0 --port 80 -n strigus
```

Opção 2 (Recomendada)
A forma mais recomendada para criar via linha de comando é usar o dry run e exportar a saída para um arquivo, com base nesse saída revisar se estão todos os parâmetros presentes e depois executar a criação

```bash
#Comando para executar o dry run
kubectl run giropops --image nginx:1.18.0 --port 80 --namespace strigus --dry-run=client -o yaml > pod.yaml

#Efetiva a criação do pod
kubectl create -f pod.yaml
```

---

### Questão 2
Aumentar a quantidade de réplicas do deployment girus, que está utilizando a imagem do nginx 1.18.0, para 3 replicas. O deployment está no namespace strigus.

<b>Resposta 2</b>

Verificar se o deployment está em execução, (durante a prova o deployment já deve estar criado, mas agora vamos para ter o ambiente pronto para a execução da resposta)
```bash

# Verificar se o deploy está presente 
kubectl -n strigus get deploy

# Criar o yaml do deploy para poder alterar o número de replicas 
kubectl create deployment girus --image nginx:1.18.0 --port 80 --namespace strigus --dry-run=client -o yaml > deployment.yaml

kubectl create -f deployment.yaml    

## Validar se está lá
kubectl -n strigus get deploy

# A resposta é alterar o numero de replicar de um deploy que está rodando
# para isso é só executar o comando abaixo.
kubectl scale deployment -n strigus girus --replicas 3
```

Opcional:

```bash
#É possível criar um deployment com o valor de replicas e aplicar sobre o deployment que já esta rodando

# dry-run
kubectl create deployment girus --image nginx:1.18.0 --port 80 --namespace strigus --replicas 3 --dry-run=client -o yaml > deployment_r3.yaml

# apply
kubectl apply -f deployment_r3.yaml
```

Opcional 2: Editando o deployment, ao sair e salvar o novo valor será aplicado 
```bash
# lá dentro, alteramos a qtde de replicas e saimos.
kubectl edit deployment -n strigus girus 
```


<br>

### Questão 3
Precisamos atualizar a versão do Nginx do Pod giropops. Ele está na versão 1.18.0 e precisamos atualizar para versão 1.21.1

Opção 1: 
```bash
# validar qual a versão atual
kubectl -n strigus describe pod giropops
# lá mudamos a versão do Nginx
kubectl -n strigus edit pod giropops 


kubectl -n strigus edit pod giropops
```

```bash
kubectl set image pod giropops -n strigus web=nginx:1.21.0

#Meu caso
kubectl -n strigus set image pod giropops giropops=nginx:1.21.1


kubectl -n NAME_SPACE set image pod POD_NAME CONTAINER_NAME=nginx:1.21.1
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: giropops
  name: giropops < ==
  namespace: strigus < ==
spec:
  containers:
  - image: nginx:1.18.0
    name: giropops < ==
    ports:
    - containerPort: 80
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```



```bash
kubectl get pods -n strigus giropops -o yaml > pod4.yaml
# Lembre-se de remover tudo o que não é necessario.

kubectl apply -f pod4.yaml
```


## Day 02

<br>

### Quantos nodes são works?
```bash
kubectl get nodes
```

```
NAME      STATUS   ROLES                  AGE   VERSION
kube-m1   Ready    control-plane,master   14d   v1.23.1
kube-w1   Ready    <none>                 12d   v1.23.1
kube-w2   Ready    <none>                 12d   v1.23.1
```

### Quantos nodes são masters?
```bash
kubectl get nodes
```

### Qual o Pod Network (CNI) que estamos utilizando? São pods plugins para controlar a rede

```bash
kubectl get ns #para achar o nome space kube-system
kubectl get pods -n kube-system
```
ou
```
ssh NODE
cd /etc/cni
ls -lha
```

## Qual o CIDR dos pods no segundo workers

--> 10.32.0.0/12

```bash
#op1
kubectl get node -o jsonpath="{range .items[*]}{.metadata.name} {.spec.podCIDR}"

#op2
kubectl cluster-info dump | grep -i cidr

#op3
kubectl describe nodes | grep podCIDR

#op4
sudo grep -i cird /etc/kubernetes/manifests/kube-apiserver.yaml
```

### Qual o serviço de DNS do cluster?

```bash
kubectl get ns #para achar o nome space kube-system
kubectl get pods -n kube-system
```


### Adicionar as informações coletadas no arquivo cluster_info.txt

```
Quantos nodes são works?
Workers:
2
kube-w1
kube-w2

Quantos nodes são masters?
Control-plane:
1
kube-m1

Qual o Pod Network (CNI) que estamos utilizando? 
weave-net

Qual o CIDR dos pods no segundo workers
10.32.0.0/12

Qual o serviço de DNS do cluster?
coredns
```

## Questão 2

Precisamos criar um pod com 3 container que irão complementar a informação entre os container.
O primeiro container será um nginx que receberá dados no arquivo index.html para que a comunicação entre os container ocorra eles irão compartilar o mesmo volume, no caso o volume workdir

O container 2 será um busybox que salvará dados no arquivo index.html utilzando o comando abaixo
```bash
=> command: ["sh", "-c", "while true; do uname -a >> /tmp/index.html; date >> /tmp/index.html; sleep 2; done"]
```
O container 3 será outro busybox que ficará monitorando conteudo do arquivo index.html com o comando abaixo.
```bash
=> command: ["sh", "-c", "tail -f /tmp/index.html"]
```

## reposta

```
kubectl run container01 --image nginx:1.18.0 --port 80 --dry-run=client -o yaml > pod.yaml

kubectl create -f day-02/pod.yaml

kubectl logs -f meu-pod container-1
kubectl logs -f meu-pod container-2
kubectl logs -f meu-pod container-3
kubectl exec -ti meu-pod -c container-1 -- bash
```


## Day 03

<br>

### Questão 01 -  Criar um pod estático utilizando a imagem do nginx.

https://kubernetes.io/docs/tasks/configure-pod-container/static-pod/

Post estático é um pod que é criado no manifesto do kubernet, e gerenciado pelo nó onde foi criado o manifesto

>The kubelet automatically tries to create a mirror Pod on the Kubernetes API server for each static Pod. This means that the Pods running on a node are visible on the API server, but cannot be controlled from there. The Pod names will be suffixed with the node hostname with a leading hyphen.


```bash
cd /etc/kubernetes/manifests
k run giropops --image nginx -o yaml --dry-run=client > meu-pod-estatico.yaml

sudo mv meu-pod-estatico.yaml > /etc/kubernetes/manifests/

systemctl restart kubelet
```

### Questão 02 - O nosso gerente está assustado, pois conversando com o gerente de uma outra empresa, ficou sabendo que aconteceu uma indisponibilidade no ambiente Kubernetes de lá por conta de certificados expirados. Ele está demasiadamente preocupado. Ele quer que tenhamos a certeza de que nosso cluster não corre esse perigo, portanto, adicione no arquivo /tmp/meus-certificados.txt todos eles e suas datas de expiração.

Resposta 01: 
Os certificados, por padrao, ficam no diretório /etc/kubernetes/pki. Para que você possa verificar a data de expiração, você pode utilizar o comando openssl, conforme abaixo:
```bash
cd /etc/kubernetes/pki
openssl x509 -noout -text -in apiserver.crt | grep -i "not after"
```

Resposta 02: 
Lembrar de adicionar a data de expiração no arquivo solicitado na questão.

Caso queira fazer de uma forma mais bonitinha, e automagicamente pegar as datas e já adicionar ao arquivo, faça conforme abaixo:
```bash
find /etc/kubernetes/pki/ -iname "apiserver*crt" -exec openssl x509 -noout -subject -enddate -in {} \; >> /tmp/meus-certificados.txt
```

Resposta 03: 

```bash
kubeadm certs check-expiration >> /tmp/meus-certificados.txt
```

### Questão 03 - Pois bem, vimos que precisamos atualizar o nosso cluster imediatamente, sem trazer nenhum indisponibilidade para o ambiente. Como devemos proceder?

Pois bem, vimos que precisamos atualizar o nosso cluster imediatamente, sem trazer nenhum indisponibilidade para o ambiente. Como devemos proceder?

Resposta: 
Podemos utilizar o comando kubeadm certs para visualizar as datas corretas e tbm para realizar sua renovação. Conforme estamos fazendo abaixo:
```bash
kubeadm certs renew all
```

Lembrando a importância de realizar o procedimento em todos os nodes master. Lembre se restartar o apiserver, controller, scheduller e o etcd. Para isso, você pode utilizar o comando docker stop, de dentro do node que está sendo atualizado.


> You must restart the kube-apiserver, kube-controller-manager, kube-scheduler and etcd, so that they can use the new certificates.
```
sudo systemctl restart kubelet

```



## Day 04

<br>

### Questão 01 - Precisamos subir um container em um node master. Esse container tem que estar rodando a imagem do nginx, o nome do pod é pod-web e o container é container-web. Sua namespace será a catota.

Resposta:
```bash
kubectl run pod-web --image nginx -o yaml --dry-run=client > pod-web.yaml

kubectl get nodes
kubectl describe node kube-m1

kubectl describe node kube-m1 | grep NoSchedule
-> Taints:             node-role.kubernetes.io/master:NoSchedule
```
Node com o Taints NoSchedule não aceitam receber novos pods (mas mantem todos que já estão no nó)

>NoExecute ele remove todos os pods enviando para outros nós que possam receber esses pods

```bash
kubectl create ns catota
kubectl create -f pod-web.yaml
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: pod-web
  name: pod-web
  namespace: catota
spec:
  containers:
  - image: nginx
    name: container-web
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
  tolerations: 
  - effect: NoSchedule
    operator: Equal
    key: node-role.kubernetes.io/master
  nodeSelector:
    node-role.kubernetes.io/master: ""

```
### Questão 02 - Precisamos de algumas informações do nosso cluster e dos pods que lá estão. Portanto, precisamos do seguinte:

 01) Adicione todos os pods do cluster por ordem de criação, dentro do arquivo /tmp/pods.txt
Respota 01
```bash
kubectl describe pods pod-01
kubectl get pod pod-01 -o yaml

#Com a saida o yaml conseguimos ver qual o caminho que a informação se encontra
--------------------
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: "2022-01-22T01:19:42Z"  <--
--------------------

kubectl get pod --help
kubectl get pods --sort-by='.metadata.creationTimestamp'

#Exibe todos os pods ordenados
kubectl get pods -A --sort-by='metadata.creationTimestamp'
#Exibe apena o nome
kubectl get pods -A --sort-by='metadata.creationTimestamp' -o name > /tmp/pods.txt
#Permite customizar as colunas
kubectl get pods -A --sort-by='metadata.creationTimestamp' -o custom-columns=:.metadata.namespace,:.metadata.name > /tmp/pods.txt

```

02)  Remova um pod do weave, verifique os eventos e os adicione no arquivo /tmp/eventos.txt

```bash
kubectl get pods -n kube-system

kubectl get events -A --sort-by=.metadata.creationTimestamp

#Matando o evento
kubectl delete pod -n kube-system weave-net-nwhvq

#Salvando no arquivo
kubectl get events -A --sort-by=.metadata.creationTimestamp > /tmp/events.txt
```



 03)  Liste todos os pods que estão em execução no seul-cool-5 e os adicione no arquivo /tmp/pods-node-05.txt

```
kubectl get pod -o yaml app1-679bb7fc98-jkls5
-----------
spec:
  ...
  nodeName: kube-w2

kubectl get pods -A --field-selector='spec.nodeName=kube-w2'

kubectl get pods -A --field-selector='spec.nodeName=kube-w2' > /tmp/pods-kube-w2.txt
```


## Day 05

<br>

O ETCD é o banco de dados do cluster, somente o api service que tem acesso ao ETCD

Backing up an etcd cluster 
https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/

### Questão 01 - O nosso gerente solicitou que seja feita agora, um backup/snapshot do nosso ETCD. Ele ficou muito assustado em saber que se perdermos o ETCD, perderemos o nosso cluster e, consequentemente, a nossa tranquilidade! Portanto, bora fazer esse snapshot imediatamente!

```
sudo apt install etcd-client

ssh node-master # Um dos nodes onde o ETCD está em execução.
cd /etc/kubernetes/manifests
cat etcd.yaml
grep etcd kube-apiserver.yaml

# Com essas informaçoes, já podemos criar o nosso snapshot
ETCDCTL_API=3 etcdctl snapshot save snap_do_gerente.db --key /etc/kubernetes/pki/apiserver-etcd-client.key --cacert /etc/kubernetes/pki/etcd/ca.crt --cert /etc/kubernetes/pki/apiserver-etcd-client.crt


ETCDCTL_API=3 etcdctl --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/apiserver-etcd-client.crt --key=/etc/kubernetes/pki/apiserver-etcd-client.key snapshot save snap-do-gerente.db
```


### Questão 02 - Muito bem, o gerente está feliz, mas não perfeitamente explendido em sua felicidade! A pergunta do gerente foi a seguinte: Você já fez o restore para testar o nosso snapshot? EU QUERO TESTAR AGORA!

```
ETCDCTL_API=3 etcdctl snapshot restore snap_do_gerente.db --data-dir /tmp/etcd-test
```


## Day 06

### Questão 01 - O nosso gerente observou no dashboard do Lens que um dos nossos nodes não está bem. Temos algum problema com o nosso cluster e precisamos resolver agora.

Respota:
```bash
kubectl get nodes
ssh node_com_problema
ps -ef | grep kubelet
docker ps
systemctl status kubelet
journalctl -u kubelet
whereis kubelet
vim /etc/systemd/system/kubelet.service.d/10-kubeadm.conf # ARRUMAR O PATH DO
# systemctl edit --full kubelet # ainda podemos usar esse comando ao inves de
# alterar o arquivo
BINARIO DO KUBELET
systemctl daemon-reload
systemctl restart kubelet
systemctl status kubelet
journalctl -u kubelet
```

```bash
#Alternativa
sudo systemctl edit --full kubelet
```


### Questao 02 - Temos um secret com o nome e senha de um usuário que nossa aplicação irá utilizar, precisamos colocar esse secret em um pod. Detalhe: Esse secret deve se tornar uma variável de ambiente dentro do container.

Respota:
```bash

kubectl create secret generic credentials --from-literal user=silva --from-literal password=senha1 --dry-run=client -o yaml > meu_secret.yaml

kubectl create -f meu_secret.yaml

kubectl run giropops --image nginx --dry-run=client -o yaml > pod_com_secret.yaml

kubectl create -f pod_com_secret.yaml
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: giropops
  name: giropops
spec:
  containers:
  - image: nginx
    name: giropops
    resources: {}
    env:
    - name: MEU_USER
      valueFrom:
        secretKeyRef:
          name: credentials
          key: user
    - name: MEU_PASSWORD
      valueFrom:
        secretKeyRef:
          name: credentials
          key: password
    volumeMounts:
    - name: credentials
      mountPath: /opt/giropops
      
  dnsPolicy: ClusterFirst
  restartPolicy: Always

  volumes:
  - name: credentials
    secret:
      secretName: credentials
```



## Day 07

### Questão 01 - Precisamos subir um pod, fácil não? Porém esse pod somente poderá ficar disponível quando um determinado service estiver no ar. O serviço deverá ser um simples Nginx. O pod, nós teremos mais detalhes durante a resolução.


OBS: 
  livenessProbe indica se o pod está vivo
  readinessProbe indica se o pod está pronto para receber requesições

Respota:
```bash
 k run waiting-nginx --image nginx --dry-run=client -o yaml > waiting-nginx.yaml
 kubectl create -f waiting-nginx.yaml
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: waiting-nginx
  name: waiting-nginx
spec:
  containers:
  - image: nginx
    name: waiting-nginx
    resources: {}
    livenessProbe:
      exec:
        command:
        - 'true'
    readinessProbe:
      exec:
        command:
        - sh
        - c
        - 'curl http://my-nginx:80'
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}

```

```bash
 kubectl run my-nginx --image nginx --dry-run=client -o yaml > my-nginx.yaml
 kubectl create -f my-nginx.yaml
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: my-nginx
  name: my-nginx
spec:
  containers:
  - image: nginx
    name: my-nginx
    ports:
    - containerPort: 80
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```

```bash
kubectl create -f my-nginx.yaml
kubectl expose pod my-nginx

kubectl get pods
kubectl describe pods giropops
```



## Day 08

### Questão 01 - Hoje o nosso gerente pediu para que fiquemos confortáveis com o gerenciamento de contextos do nossos clusters. Ele está com medo de que executemos algo em ulgum cluster errado, e assim deixando o nosso dia muito mais chatiante!


Resposta 1 (clique para ver a resposta)
Criamos dois clusters, para que pudessemos brincar com os contextos. Para criar os cluster, nós utilizamos o Kind, e para criar o cluster, nós estamos utilizando um arquivo template, conforme abaixo:

kind-cluster-1.yaml
```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
```

```bash
kind create cluster --name lt-01 --config kind-cluster-1.yaml
```

kind-cluster-2.yaml
```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
```

```bash
kind create cluster --name giropops-01 --config kind-cluster-2.yaml
```


Agora que os nossos clusters já estão criados, bora brincar com os contextos.

Para visualizar os contextos, utilize o comando abaixo:

```bash
kubectl config get-contexts
```

Para selecionar determinado contexto, utilize:

```bash
kubectl config use-context CONTEXTO_DESEJADO
```

Vale lembrar que os contextos estão definidos no seu arquivo config, na maioria dos casos no ${HOME}/.kube/config.


### Questão 02 - Precisamos criar um pod com o Nginx rodando no cluster lt-01, já no cluster giropops-01, nós precisamos ter um deployment do Nginx e um service apontando para esse deployment. Os containers deverão ter o mesmo nome em todos os cluster e estarem rodando no namespace strigus.!

```bash
kubectl config current-context
kubectl config use-context kind-lt-01
kubectl run --image nginx strigus-01 --port 80 --namespace strigus --dry-run=client -o yaml > meu_pod.yaml
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: strigus-01
  name: strigus-01
  namespace: strigus
spec:
  containers:
  - image: nginx
    name: strigus-01
    ports:
    - containerPort: 80
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```

```bash
kubectl create ns strigus
kubectl create -f meu_pod.yaml
```

Trocando de contexto

```bash
kubectl config current-context
kubectl config use-context kind-giropops-01

kubectl create deployment giropops --image nginx --port 80 --namespace strigus --dry-run=client -o yaml > meu_deployment.yaml
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: giropops
  name: giropops
  namespace: strigus
spec:
  replicas: 1
  selector:
    matchLabels:
      app: giropops
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: giropops
    spec:
      containers:
      - image: nginx
        name: strigus-01
        ports:
        - containerPort: 80
        resources: {}
status: {}
```

```bash
kubectl create ns strigus
kubectl create -f meu_deployment.yaml
kubectl expose deployment --namespace strigus giropops


```

Note que temos containers rodando.

```bash
docker container ls --filter "label=io.x-k8s.kind.role"
```

Vamos deletar os 2 clusters criados anteriormente.
```bash
kind delete cluster --name lt-01
kind delete cluster --name giropops-01
```


## Day 09

### Questão 01 - Nosso gerente precisa reportar para o nosso diretor, quais as namespaces que nós temos hoje em produção. Salvar a lista de namespaces no arquivo /tmp/giropops-k8s.txt

```bash
kubectl get ns --no-headers -o custom-columns=":metadata.name" > /tmp/list-namespaces
```

### Questão 02 - Precisamos criar um pod chamado web e utilizando a imagem do Nginx na versão 1.21.4. O pod deverá ser criado no namespace web-1 e o container deverá se chamar meu-container-web. O nosso gerente pediu para que seja criado um script que retorne o status desse pod que iremos criar. O nome do script é /tmp/script-do-gerente-toskao.sh


```bash
kubectl create ns web-1
kubectl run meu-container-web --image nginx:1.21.4 --port 80 --dry-run=client -o yaml > meu-container-web.yaml

#Para descobrir a estrutuda de dados para usar no custom-columns
kubectl get  pods -n web-1 meu-container-web -o yaml

kubectl get pods -n web-1 -o custom-columns=":metadata.name, :status.phase"

echo 'kubectl get pods -n web-1 -o custom-columns=":metadata.name, :status.phase"' > /tmp/script-status-pod-meu-web-container.sh

chmod +x /tmp/script-status-pod-meu-web-container.sh
/tmp/script-status-pod-meu-web-container.sh

```


### Questão 3 - Criamos o pod do Nginx, parabéns! 

- TASK-1: Portanto, agora precisamos mudar a versão do Nginx para a versão 1.18.0, pois o
nosso gerente viu um artigo no Medium e disse que agora temos que usar essa
versão e ponto.

<details>
  <summary><b>Resposta TASK-1</b> <em>(clique para ver a resposta)</em></summary>
>Quando usamos apenas pods não conseguimos alterar a imagem usando set e nem rollout, para isso precisamos de um deployment 

```bash
kubectl edit pods -n web-1 web
```
</details>

- TASK-2: Precisamos criar um deployment no lugar do nosso pod do Nginx

<details>
  <summary><b>Resposta TASK-2</b> <em>(clique para ver a resposta)</em></summary>

```bash
kubectl create deployment web --image nginx:1.20.2 --dry-run=client -o yaml > deployment.yaml
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: web
  name: web
  namespace: web-1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: web
    spec:
      containers:
      - image: nginx:1.20.2
        name: meu-container-web
        resources: {}
status: {}
```
</details>

- TASK-3: Precisamos utilizar o Nginx com a imagem do Alpine, pq o gerente leu um outro artigo no Medium.

<details>
  <summary><b>Resposta TASK-3</b> <em>(clique para ver a resposta)</em></summary>

```bash
kubectl edit deployment -n web-1 web
```
</details>

- TASK-4: Precisamos realizar o rollback do nosso deployment web

<details>
  <summary><b>Resposta TASK-4</b> <em>(clique para ver a resposta)</em></summary>

```bash
kubectl rollout history deployment -n web-1 web
kubectl rollout history deployment -n web-1 web --revision=1
kubectl rollout history deployment -n web-1 web --revision=2
kubectl rollout undo deployment -n web-1 web --to-revision=1
```
</details>


https://school.linuxtips.io/courses/1259521/lectures/36978807

1:20:00



