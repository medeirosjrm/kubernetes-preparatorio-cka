# Volumes

## EmptyDir

Um volume do tipo EmptyDir é criado sempre que um Pod é atribuído a um nó existente. Esse volume é criado inicialmente vazio, e todos os contêineres do Pod podem ler e gravar arquivos no volume.

Esse volume não é um volume com persistência de dados. Sempre que o Pod é removido de um nó, os dados no EmptyDir são excluídos permanentemente. É importante ressaltar que os dados não são excluídos em casos de falhas nos contêineres.

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: busybox
  name: busybox
spec:
  containers:
  - image: busybox
    name: busybox
    command:
      - sleep
      - "3600"
    volumeMounts:
    - mountPath: /giropops
      name: vol-giropops
  
  volumes:
  - name: vol-giropops
    emptyDir: {}

```

## Persistent Volume

Persistent Volume
O subsistema PersistentVolume fornece uma API para usuários e administradores que resume detalhes de como o armazenamento é fornecido e consumido pelos Pods. Para o melhor controle desse sistema foi introduzido dois recursos de API: PersistentVolume e PersistentVolumeClaim.

Um PersistentVolume (PV) é um recurso no cluster, assim como um nó. Mas nesse caso é um recurso de armazenamento. O PV é uma parte do armazenamento no cluster que foi provisionado por um administrador. Os PVs tem um ciclo de vida independente de qualquer pod associado a ele. Essa API permite armazenamentos do tipo: NFS, ISCSI ou armazenamento de um provedor de nuvem específico.

Um PersistentVolumeClaim (PVC) é semelhante a um Pod. Os Pods consomem recursos de um nó e os PVCs consomem recursos dos PVs.

Mas o que é um PVC? Nada mais é do que uma solicitação de armazenamento criada por um usuário.

Vamos criar um PersistentVolume do tipo NFS, para isso vamos instalar os pacotes necessários para criar um NFS Server no GNU/Linux.

Exemplo usando NFS

```bash
# instalar pacotes
sudo apt-get install -y nfs-kernel-server
sudo apt-get install -y nfs-common

# criar a pasta 
sudo mkdir /opt/dados
sudo chmod 1777 /opt/dados/

# configuração
sudo vim /etc/exports
# adicionar essa linha no exports 
/opt/dados *(rw,sync,no_root_squash,subtree_check)

# aplicar as configurações do export
sudo exportfs -a
# reiniciar o serviço
sudo systemctl restart nfs-kernel-server

# testar se a configuração deu certo
sudo showmount -e 192.168.1.211
---

  Export list for 192.168.1.211:
  /opt/dados *

---

```

## Criar o primeiro PV

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: primeiro-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
  - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  nfs:
    path: /opt/dados
    server: 192.168.1.211
    readOnly: false
```

```
 kubectl get pv 
 ---
NAME          CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
primeiro-pv   1Gi        RWX            Retain           Available                                   5s


kubectl describe pv primeiro-pv
--
Name:            primeiro-pv
Labels:          <none>
Annotations:     <none>
Finalizers:      [kubernetes.io/pv-protection]
StorageClass:    
Status:          Available
Claim:           
Reclaim Policy:  Retain
Access Modes:    RWX
VolumeMode:      Filesystem
Capacity:        1Gi
Node Affinity:   <none>
Message:         
Source:
    Type:      NFS (an NFS mount that lasts the lifetime of a pod)
    Server:    192.168.1.211
    Path:      /opt/dados
    ReadOnly:  false
Events:        <none>
```

## Persistent Volume Claim

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: primeiro-pvc
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 800Mi
```

```
kubectl get pvc
--
NAME           STATUS   VOLUME        CAPACITY   ACCESS MODES   STORAGECLASS   AGE
primeiro-pvc   Bound    primeiro-pv   1Gi        RWX                           9s
```



