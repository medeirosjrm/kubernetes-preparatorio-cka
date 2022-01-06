# Processo de instalação do nó master


## Configurar os hosts e ip fixo

```
hostnamectl set-hostname kube-m1

nano /etc/hosts

127.0.0.1       localhost
127.0.1.1       kube-m1

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

```
cat /etc/network/interfaces

#The primary network interface
auto eth0
iface eth0  inet static
 address 192.168.1.220
 netmask 255.255.255.0
 gateway 192.168.1.1
 dns-domain debian.local
 dns-nameservers 192.168.1.1

```

## Instalação em cluster com três nós

### Requisitos básicos

Como já dito anteriormente, o Minikube é ótimo para desenvolvedores, estudos e testes, mas não tem como propósito a execução em ambiente de produção. Dito isso, a instalação de um *cluster* k8s para o treinamento irá requerer pelo menos três máquinas, físicas ou virtuais, cada qual com no mínimo a seguinte configuração:

- Distribuição: Debian, Ubuntu, CentOS, Red Hat, Fedora, SuSE;

- Processamento: 2 *cores*;

- Memória: 2GB.

### Configuração de módulos de kernel

O k8s requer que certos módulos do kernel GNU/Linux estejam carregados para seu pleno funcionamento, e que esses módulos sejam carregados no momento da inicialização do computador. Para tanto, crie o arquivo ``/etc/modules-load.d/k8s.conf`` com o seguinte conteúdo em todos os seus nós.

```
br_netfilter
ip_vs
ip_vs_rr
ip_vs_sh
ip_vs_wrr
nf_conntrack_ipv4
```


## Como dar permissão de sudo

Subir para o nível de su

```
su -
```

Instalar o sudo 
```
apt-get install sudo -y
```

Dar permissão para o grupo
```
usermod -aG sudo silva
```

Conferir o arquivo /etc/sudoers
```
# Allow members of group sudo to execute any command
%sudo   ALL=(ALL:ALL) ALL
```

>Depois de fazer a alterações RELOGAR no sistema


### Instalar o docker

```bash
sudo apt install -y curl

curl -fsSL https://get.docker.com | bash

sudo groupadd docker
sudo usermod -aG docker $USER
#log out and log back
exit
```

Configurações adicionais
https://kubernetes.io/docs/setup/production-environment/container-runtimes/

```bash
sudo mkdir /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

#sudo mkdir -p /etc/systemd/system/docker.service.d
sudo systemctl enable docker
sudo systemctl daemon-reload
sudo systemctl restart docker
```

Validar se o drive Cgroup foi defidamente configurado
```
docker info | grep -i cgroup
---
 Cgroup Driver: systemd
 Cgroup Version: 2
  cgroupns
```


### Instalação dos repositórios do k8s e kubeadm

https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/

1. Update the apt package index and install packages needed to use the Kubernetes apt repository:
```
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
```

2. Download the Google Cloud public signing key:

```
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
```

3. Add the Kubernetes apt repository:

```
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

4. Update apt package index, install kubelet, kubeadm and kubectl, and pin their version:

```
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```


### Desativando swap
https://unix.stackexchange.com/questions/224156/how-to-safely-turn-off-swap-permanently-and-reclaim-the-space-on-debian-jessie

1. If you have GParted open, close it. Its Swapoff feature does not appear to to be permanent.

2. Open terminal and become root (su); if you have sudo enabled, you may also do for example sudo -i; see man sudo for all options):

```
sudo -i
```
3. Turn off the particular swap partition and / or all of the swaps:

```
swapoff --all
```

4. Make 100% sure the particular swap partition partition is off:

```
cat /proc/swaps
```

5. Open a text editor you are skilled in with this file, e.g. nano if unsure:

```
nano /etc/fstab
```

6. Comment out / remove the swap partition's UUID, e.g.:

```
# UUID=1d3c29bb-d730-4ad0-a659-45b25f60c37d    none    swap    sw    0    0
```

7. Open a text editor you are skilled in with this file, e.g. nano if unsure:

```
nano /etc/initramfs-tools/conf.d/resume
```
8. Comment out / remove the previously identified swap partition's UUID, e.g.:

```
# RESUME=UUID=1d3c29bb-d730-4ad0-a659-45b25f60c37d
```



### Inicialização do cluster

Antes de inicializarmos o cluster, vamos efetuar o download das imagens que serão utilizadas, executando o comando a seguir no nó que será o master.
```
sudo kubeadm config images pull
```

Execute o comando a seguir também apenas no nó master para a inicialização do cluster. Caso tudo esteja bem, será apresentada ao término de sua execução o comando que deve ser executado nos demais nós para ingressar no cluster.

```bash
sudo kubeadm init

#Caso de erro, checkar se desativou o swamp e usar o comando kubeadm reset, depois o init novamente

```
Resultado:
```
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.1.220:6443 --token 3691jv.r8l1zenfoohqcsaf \
        --discovery-token-ca-cert-hash sha256:1410837b320bf702c8f563f1234e8c41421cae343578f67528fcf7f24a97131f
```


```
kubectl describe node elliot-1 | grep InternalIP
```

### Inicialização do bash completion

```
sudo apt-get install bash-completion
source /usr/share/bash-completion/bash_completion
echo 'source <(kubectl completion bash)' >>~/.bashrc
```

