## Rollouts e Rollbacks

Agora vamos imaginar que essa nossa última edição utilizando o comando kubectl set no DaemonSet não foi correta e precisamos voltar a configuração anterior, onde a versão da imagem era outra, como faremos?

É muito simples, para isso existe o Rollout. Com ele você pode verificar quais foram as modificações que aconteceram em seu Deployment ou DaemonSet, como se fosse um versionamento. Vejaaaa! (Com a voz do Nelson Rubens)

```bash
kubectl rollout history ds daemon-set-primeiro

daemonsets "daemon-set-primeiro"
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
```

Ele irá mostrar duas linhas, a primeira que é a original, com a imagem do nginx:1.7.9 e a segunda já com a imagem nginx:1.15.0. As informações não estão muito detalhadas concordam?

Veja como verificar os detalhes de cada uma dessas entradas, que são chamadas de revision.

Visualizando a revision 1:

```
kubectl rollout history ds daemon-set-primeiro --revision=1

daemonsets "daemon-set-primeiro" with revision #1
Pod Template:
  Labels:	system=DaemonOne
  Containers:
   nginx:
    Image:	nginx:1.7.9
    Port:	80/TCP
    Host Port:	0/TCP
    Environment:	<none>
    Mounts:	<none>
  Volumes:	<none>
```

Visualizando a revision 2:
```
kubectl rollout history ds daemon-set-primeiro --revision=2

daemonsets "daemon-set-primeiro" with revision #2
Pod Template:
  Labels:	system=DaemonOne
  Containers:
   nginx:
    Image:	nginx:1.15.0
    Port:	80/TCP
    Host Port:	0/TCP
    Environment:	<none>
    Mounts:	<none>
  Volumes:	<none>
```

Para voltar para a revision desejada, basta fazer o seguinte:

```
kubectl rollout undo ds daemon-set-primeiro --to-revision=1

daemonset.extensions/daemon-set-primeiro rolled back
```
Perceba que trocamos o history por undo e o revision por to-revision, assim faremos o rollback em nosso DaemonSet, e voltamos a versão da imagem que desejamos. 😃


> Atenção!!! Por padrão, o DaemonSet guarda apenas as 10 últimas revisions. Para alterar a quantidade máxima de revisions no nosso Daemonset, execute o seguinte comando. Fonte: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#clean-up-policy

```
kubectl edit daemonsets.apps daemon-set-primeiro

  revisionHistoryLimit: 10
```

Voltando à nossa linha de raciocínio, para acompanhar o rollout, execute o seguinte comando:
```
kubectl rollout status ds daemon-set-primeiro
```

Vamos afinar esse nosso DaemonSet, vamos adicionar o RollingUpdate e esse cara vai atualizar automaticamente os Pods quando houver alguma alteração.

Vamos lá, primeiro vamos remover o DaemonSet, adicionar duas novas informações em nosso manifesto yaml e, em seguida, criar outro DaemonSet em seu lugar:

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
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
  updateStrategy:
    type: RollingUpdate
```

Visualizando o status do rollout:
```
kubectl rollout status ds daemon-set-primeiro

daemon set "daemon-set-primeiro" successfully rolled out
```