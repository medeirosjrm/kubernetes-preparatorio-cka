# Questões CKA


## Day 01

<br>

### Questão 1
Criar um pod utilizando a imagem do Nginx 1.18.0, com o nome de giropops no namespace strigus.

  
<b>Resposta 1</b>

Passo 1 
```bash
#Verificar se o namespace está presente
kubectl get ns      

#Caso seja necessário cria-lo
kubectl create ns strigus
```

Passo 2

A forma mais recomendada para criar via linha de comando é usar o dry run e exportar a saída para um arquivo, com base nesse saída revisar se estão todos os parâmetros presentes e depois executar a criação

```bash
#Comando para executar o dry run
kubectl run giropops --image nginx:1.18.0 --port 80 --namespace strigus --dry-run=client -o yaml > pod.yaml

#Efetiva a criação do pod
kubectl create -f pod.yaml
```


Outra forma de criar o pod

```bash
#Diretamente pelo comando run
kubectl run giropops --image nginx:1.18.0 --port 80 --namespace strigus
```

---

### Questão 2
Aumentar a quantidade de réplicas do deployment girus, que está utilizando a imagem do nginx 1.18.0, para 3 replicas. O deployment está no namespace strigus.

<b>Resposta 2</b>

Passo 1: Verificar se o deployment está em execução, (durante a prova o deployment já deve estar criado, mas agora vamos para ter o ambiente pronto para a execução da resposta)
```bash
kubectl create deployment girus --image nginx:1.18.0 --port 80 --namespace strigus --dry-run=client -o yaml > deployment.yaml

kubectl create -f deployment.yaml    
```

Passo 2:  Aqui é a resposta correta da questão
```bash
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
# lá mudamos a versão do Nginx
kubectl edit pod -n strigus giropops 


kubectl -n strigus edit pod giropops
 kubectl -n strigus describe pod giropops
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