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

Vamos instalar os pacotes no node elliot-01.