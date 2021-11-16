# Preparatório para o CKA


## Ambiente Windows usando Hyper-v

[Tutorial](hyper-v/README.md)


## Conceitos-chave do k8s
É importante saber que a forma como o k8s gerencia os contêineres é ligeiramente diferente de outros orquestradores, como o Docker Swarm, sobretudo devido ao fato de que ele não trata os contêineres diretamente, mas sim através de pods. Vamos conhecer alguns dos principais conceitos que envolvem o k8s a seguir:

**Pod:** é o menor objeto do k8s. Como dito anteriormente, o k8s não trabalha com os contêineres diretamente, mas organiza-os dentro de pods, que são abstrações que dividem os mesmos recursos, como endereços, volumes, ciclos de CPU e memória. Um pod, embora não seja comum, pode possuir vários contêineres;

**Controller:** é o objeto responsável por interagir com o API Server e orquestrar algum outro objeto. Exemplos de objetos desta classe são os Deployments e Replication Controllers;

**ReplicaSets:** é um objeto responsável por garantir a quantidade de pods em execução no nó;

**Deployment:** É um dos principais controllers utilizados. O Deployment, em conjunto com o ReplicaSet, garante que determinado número de réplicas de um pod esteja em execução nos nós workers do cluster. Além disso, o Deployment também é responsável por gerenciar o ciclo de vida das aplicações, onde características associadas a aplicação, tais como imagem, porta, volumes e variáveis de ambiente, podem ser especificados em arquivos do tipo yaml ou json para posteriormente serem passados como parâmetro para o kubectl executar o deployment. Esta ação pode ser executada tanto para criação quanto para atualização e remoção do deployment;

**Jobs e CronJobs:** são objetos responsáveis pelo gerenciamento de jobs isolados ou recorrentes.


## Kubectl describe

[Readme](kube-describe.md)

## Kubectl taints

[Readme](kube-taints.md)


## Como recuperar o Token para adicionar mais nós?

```
kubeadm token create --print-join-command 
``` 


## Como adicionar o completion?

https://kubernetes.io/docs/tasks/tools/included/optional-kubectl-configs-bash-linux/


```bash

sudo apt install bash-completion

sudo touch /etc/bash_completion.d/kubectl


kubectl completion bash > /etc/bash_completion.d/kubectl

# BASH
source <(kubectl completion bash) # configura o autocomplete na sua sessão atual (antes, certifique-se de ter instalado o pacote bash-completion).

echo "source <(kubectl completion bash)" >> ~/.bashrc # add autocomplete permanentemente ao seu shell.

#ZSH
source <(kubectl completion zsh)

echo "[[ $commands[kubectl] ]] && source <(kubectl completion zsh)"

```

## Kubectl namespace

[Readme](kube-namespace.md)


## Pods

[Readme](kube-pods.md)


## Componentes do K8s

O k8s os principais componentes:

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



## Services

[Readme](kube-service.md)


...Limitando recursos - parte 01...