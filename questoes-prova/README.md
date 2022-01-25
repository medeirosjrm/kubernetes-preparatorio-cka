# Questões CKA


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
