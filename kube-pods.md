## Namespaces


https://kubernetes.io/docs/concepts/workloads/pods/


Os pods são as menores unidades de computação implantáveis ​​que você pode criar e gerenciar no Kubernetes.

Um vagem (como em um vagem de baleias ou vagem de ervilha) é um grupo de um ou mais containers, com armazenamento compartilhado e recursos de rede e uma especificação de como executar os contêineres. O conteúdo de um pod é sempre colocado e programado conjuntamente e executado em um contexto compartilhado. Um pod modela um "host lógico" específico do aplicativo: ele contém um ou mais contêineres de aplicativo que são acoplados de forma relativamente estreita. Em contextos não em nuvem, os aplicativos executados na mesma máquina física ou virtual são análogos aos aplicativos em nuvem executados no mesmo host lógico.

Assim como os contêineres de aplicativo, um pod pode conter contêineres init que são executados durante a inicialização do pod. Você também pode injetar contêineres efêmeros para depuração se seu cluster oferecer isso.

## O que é um pod?

O contexto compartilhado de um Pod é um conjunto de namespaces Linux, cgroups e potencialmente outras facetas de isolamento - as mesmas coisas que isolam um contêiner Docker. Dentro do contexto de um pod, os aplicativos individuais podem ter outros subisolamentos aplicados.

Em termos de conceitos do Docker, um Pod é semelhante a um grupo de contêineres do Docker com namespaces compartilhados e volumes de sistema de arquivos compartilhados.

## Usando pods

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx:1.14.2
    ports:
    - containerPort: 80
```

Criando o pod

```bash
kubectl apply -f https://k8s.io/examples/pods/simple-pod.yaml
```

Cada pod deve executar uma única instância de um determinado aplicativo. Se você deseja dimensionar seu aplicativo horizontalmente (para fornecer mais recursos gerais executando mais instâncias), você deve usar vários pods, um para cada instância. No Kubernetes, isso geralmente é conhecido como replicação . Os pods replicados geralmente são criados e gerenciados como um grupo por um recurso de carga de trabalho e seu controlador.


## Pods e controladores

Você pode usar recursos de carga de trabalho para criar e gerenciar vários pods para você. Um controlador para o recurso lida com a replicação, implementação e correção automática em caso de falha do pod. Por exemplo, se um nó falhar, um controlador perceberá que os pods nesse nó pararam de funcionar e criará um pod substituto. O planejador coloca o pod substituto em um nó íntegro.

Aqui estão alguns exemplos de recursos de carga de trabalho que gerenciam um ou mais pods:

- Deployment
- StatefulSet
- DaemonSet


## Continuar 
https://kubernetes.io/docs/concepts/workloads/pods/#pod-templates



Criando um pod
```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: nginx
  name: nginx
  namespace: giropops
spec:
  containers:
  - image: nginx
    imagePullPolicy: Always
    name: nginxs
    ports:
    - containerPort: 80    
  dnsPolicy: ClusterFirst
  restartPolicy: Always
```

```bash
kubectl create -f meu-primeiro.yaml
kubectl delete -f meu-primeiro.yaml

# Para gerar o arquivo yaml
kubectl run nginx --image=nginx --dry-run=client -o yaml > meu_segundo_pod.yaml
```

## Como acessar os manuais pela linha de comando
```
kubectl explain pod
```

## Capturando Eventos

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

