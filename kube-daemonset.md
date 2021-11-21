## DaemonSet

**DaemonSet** é basicamente a mesma coisa do que o ReplicaSet, com a diferença que quando você utiliza o DaemonSet você não especifica o número de réplicas, ele subirá um pod por node em seu cluster.

É sempre interessante quando criar usar e abusar das labels, assim você conseguirá ter melhor flexibilidade na distribuição mais adequada de sua aplicação.

Ele é bem interessante para serviços que necessitem rodar em todos os nodes do cluster, como por exemplo, coletores de logs e agentes de monitoração.

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: daemon-set-primeiro
spec:
  selector:
    matchLabels:
      system: Strigus
  template:
    metadata:
      labels:
        system: Strigus
    spec:
      tolerations:
      - key: node-role.kubernetes.io/master
        effect: NoSchedule
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
```

Vamos alterar a imagem desse pod diretamente no DaemonSet, usando o comando kubectl set:

```
kubectl set image ds daemon-set-primeiro nginx=nginx:1.15.0
```


##