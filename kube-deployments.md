## Deployments

O Deployment é um recurso com a responsabilidade de instruir o Kubernetes a criar, atualizar e monitorar a saúde das instâncias de suas aplicações.

Um Deployment é o responsável por gerenciar o seu ReplicaSet (que iremos falar logo menos), ou seja, o Deployment é quem vai determinar a configuração de sua aplicação e como ela será implementada. O Deployment é o controller que irá cuidar, por exemplo, uma instância de sua aplicação por algum motivo for interrompida. O Deployment controller irá identificar o problema com a instância e irá criar uma nova em seu lugar.

Quando você utiliza o kubectl create deployment, você está realizando o deploy de um objeto chamado Deployment. Como outros objetos, o Deployment também pode ser criado através de um arquivo YAML ou de um JSON, conhecidos por manifestos.

Se você deseja alterar alguma configuração de seus objetos, como o pod, você pode utilizar o kubectl apply, através de um manifesto, ou ainda através do kubectl edit. Normalmente, quando você faz uma alteração em seu Deployment, é criado uma nova versão do ReplicaSet, esse se tornando o ativo e fazendo com que seu antecessor seja desativado. As versões anteriores dos ReplicaSets são mantidas, possibilitando o rollback em caso de falhas.

As labels são importantes para o gerenciamento do cluster, pois com elas é possível buscar ou selecionar recursos em seu cluster, fazendo com que você consiga organizar em pequenas categorias, facilitando assim a sua busca e organizando seus pods e seus recursos do cluster. As labels não são recursos do API server, elas são armazenadas no metadata em formato chave-valor.

Antes nos tínhamos somente o RC, Replication Controller, que era um controle sobre o número de réplicas que determinado pod estava executando, o problema é que todo esse gerenciamento era feito do lado do client. Para solucionar esse problema, foi adicionado o objeto Deployment, que permite a atualização pelo lado do server. Deployments geram ReplicaSets, que oferecerem melhores opções do que o ReplicationController, e por esse motivo está sendo substituído.

### Como pegar os pods por um label
```bash
kubectl get pods -l dc=NL
...

kubectl get pods -l dc=UK

NAME                     READY   STATUS    RESTARTS   AGE
nginx-85dfffd44b-2b9jd   1/1     Running   0          9m34s


# Se eu quiser pegar todos os pods e os valores dos labels exibindo em uma coluna
kubectl get pods -L dc

NAME                        READY   STATUS    RESTARTS   AGE     DC
nginx-85dfffd44b-2b9jd      1/1     Running   0          10m     UK
nginx-nl-596bf8f9bb-ltt7b   1/1     Running   0          6m44s   NL
                                                                 
```

Os comandos acima também funcionam para os replicasets
```
kubectl get replicaset -L dc

NAME                  DESIRED   CURRENT   READY   AGE     DC
nginx-85dfffd44b      1         1         1       12m     UK
nginx-nl-596bf8f9bb   1         1         1       8m38s   NL

```

## Node Selector

O Node Selector é uma forma de classificar nossos nodes como por exemplo nosso node elliot-02 que possui disco SSD e está localizado no DataCenter UK, e o node elliot-03 que possui disco HDD e está localizado no DataCenter Netherlands.

Agora que temos essas informações vamos criar essas labels em nossos nodes, para utilizar o nodeSelector.

Criando a label disk com o valor SSD no worker 1:

```
kubectl label node elliot-02 disk=SSD

node/elliot-02 labeled


Listar todos os labels de um node
kubectl label nodes elliot-03 --list

```

### Para substituir o valor de um label

```
kubectl label nodes elliot-03 disk=HDD --overwrite
```


### Como criar seletores para os pods serem distribuidos

1) Adicionar o label ao nó
```bash
kubectl label node elliot-02 disk=SSD
```

2) Nas specs do container adicionamos o NodeSelector
```yaml
nodeSelector:
        disk: SSD
```

Exemplo completo
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    run: nginx
  name: terceiro-deployment
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      run: nginx
  template:
    metadata:
      creationTimestamp: null
      labels:
        run: nginx
        dc: Netherlands
    spec:
      containers:
      - image: nginx
        imagePullPolicy: Always
        name: nginx2
        ports:
        - containerPort: 80
          protocol: TCP
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
      nodeSelector:
        disk: SSD
```

Remover todas as labels dc de todos os nodes
```
kubectl label nodes dc- --all
```

## Stratefy


```yaml
spec:
  replicas: 10
  selector:
    matchLabels:
      run: nginx
  strategy:
    rollingUpdate:
      maxSurge: 1  # quantidade máxima de pods que podem ultapassar o limite de replicas durante uma atualização
      maxUnavailable: 1  # Quantidade de pods que podem ficarem indisponívels durante o update
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        dc: Netherlands
        app: giropops
        run: nginx
spec:
      containers:
      - image: nginx
        imagePullPolicy: Always
        name: nginx2
        ports:
        - containerPort: 80
          protocol: TCP
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      nodeSelector:
        dc: Netherlands
```
