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

Precisamos criar um pod com as seguintes caracteristicas:
 - Precisa ter um container rodando a imagem do Nginx, com um volume montado no diretorio html do nginx.
 - Precisa ter um outro container rodando busybox e adicionando algum conteúdo ao arquivo /tmp/index.html

```bash
=> command: ["sh", "-c", "while true; do uname -a >> /tmp/index.html; date >> /tmp/index.html; sleep 2; done"]
```
Precisamos ter um outro container rodando o busybox e executando o seguinte comando:
```bash
=> command: ["sh", "-c", "tail -f /tmp/index.html"]
```

1:32