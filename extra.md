# Links Importantes

Tipos de topologias de K8s multi-master: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/ha-topology/

Instalação kubeadm, kubelet e kubectl: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

Instalação Kubernetes multi-master: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/

HAproxy: https://www.haproxy.org/


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


## Desativando swap
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
