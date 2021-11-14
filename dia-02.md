# Componentes do K8s

O k8s tem os seguintes componentes principais:

* Master node
* Worker node
* Services
* Controllers
* Pods
* Namespaces e quotas
* Network e policies
* Storage

**kube-apiserver** é a central de operações do cluster k8s. Todas as chamadas, internas ou externas são tratadas por ele. Ele é o único que conecta no ETCD.

**kube-scheduller** usa um algoritmo para verificar em qual node o pod deverá ser hospedado. Ele verifica os recursos disponíveis do node para verificar qual o melhor node para receber aquele pod.

No ETCD são armazenados o estado do cluster, rede e outras informações persistentes.

**kube-controller-manager** é o controle principal que interage com o kube-apiserver para determinar o seu estado. Se o estado não bate, o manager irá contactar o controller necessário para checar seu estado desejado. Tem diversos controllers em uso como: os endpoints, namespace e replication.

O **kubelet** interage com o Docker instalado no node e garante que os contêineres que precisavam estar em execução realmente estão.

O kube-proxy é o responsável por gerenciar a rede para os contêineres, é o responsável por expor portas dos mesmos.

**Supervisord** é o responsável por monitorar e restabelecer, se necessário, o kubelet e o Docker. Por esse motivo, quando existe algum problema em relação ao kubelet, como por exemplo o uso do driver cgroup diferente do que está rodando no Docker, você perceberá que ele ficará tentando subir o kubelet frequentemente.

**Pod** é a menor unidade que você irá tratar no k8s. Você poderá ter mais de um contêiner por Pod, porém vale lembrar que eles dividirão os mesmos recursos, como por exemplo IP. Uma das boas razões para se ter mais de um contêiner em um Pod é o fato de você ter os logs consolidados.

O Pod, por poder possuir diversos contêineres, muitas das vezes se assemelha a uma VM, onde você poderia ter diversos serviços rodando compartilhando o mesmo IP e demais recursos.

**Services** é uma forma de você expor a comunicação através de um NodePort ou LoadBalancer para distribuir as requisições entre diversos Pods daquele Deployment. Funciona como um balanceador de carga.

## Controlers 

São objetos responsáveis por controlar objetos abaixo exemplo

Deployment > ReplicaSet > Pod (os containers de um pod compartilham os mesmo recursus, memória, cpu, IP)


## Container Network Interface
Para prover a rede para os contêineres, o k8s utiliza a especificação do CNI, Container Network Interface.

CNI é uma especificação que reúne algumas bibliotecas para o desenvolvimento de plugins para configuração e gerenciamento de redes para os contêineres. Ele provê uma interface comum entre as diversas soluções de rede para o k8s. Você encontra diversos plugins para AWS, GCP, Cloud Foundry entre outros.

Mais informações em: https://github.com/containernetworking/cni

Enquanto o CNI define a rede dos pods, ele não te ajuda na comunicação entre os pods de diferentes nodes.

As características básicas da rede do k8s são:

* Todos os pods conseguem se comunicar entre eles em diferentes nodes;
* Todos os nodes podem se comunicar com todos os pods;
* Não utilizar NAT.

Todos os IPs dos pods e nodes são roteados sem a utilização de NAT. Isso é solucionado com a utilização de algum software que te ajudará na criação de uma rede Overlay. Seguem alguns:

* Weave
* Flannel
* Canal
* Calico
* Romana
* Nuage
* Contiv
* Mais informações em: https://kubernetes.io/docs/concepts/cluster-administration/addons/


## Service

https://kubernetes.io/docs/concepts/services-networking/service/

https://kubernetes.io/pt-br/docs/tutorials/kubernetes-basics/expose/expose-intro/

## Como expor nosso pod? (Criar um service) 
```
kubectl export deployment <nome>
```

https://kubernetes.io/docs/concepts/services-networking/service/

- ClusterIP: Exposes the Service on a cluster-internal IP. Choosing this value makes the Service only reachable from within the cluster. This is the default ServiceType.

- NodePort: Exposes the Service on each Node's IP at a static port (the NodePort). A ClusterIP Service, to which the NodePort Service routes, is automatically created. You'll be able to contact the NodePort Service, from outside the cluster, by requesting <NodeIP>:<NodePort>.

- LoadBalancer: Exposes the Service externally using a cloud provider's load balancer. NodePort and ClusterIP Services, to which the external load balancer routes, are automatically created.

- ExternalName: Maps the Service to the contents of the externalName field (e.g. foo.bar.example.com), by returning a CNAME record with its value. No proxying of any kind is set up.

O service trabalha em cima do endpoint, quando chega uma requisição no service ele deve procurar para quem enviar aquela requisição com base nos endpoints criados


Exemplo:

```
kubectl create -f meu-primeiro.yaml

kubectl get pods -n giropops 
NAME    READY   STATUS              RESTARTS   AGE
nginx   0/1     ContainerCreating   0          27s



kubectl expose pod nginx --port=80 -n giropops
service/nginx exposed


kubectl get services -n giropops
NAME    TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
nginx   ClusterIP   10.105.62.75   <none>        80/TCP    41s


kubectl get endpoints -n giropops
NAME    ENDPOINTS        AGE
nginx   10.244.0.25:80   62s

Test
curl 10.244.0.25


```

https://school.linuxtips.io/courses/1259521/lectures/28043262
  Services - parte 01