# InitContainer

## EmptyDir

O objeto do tipo InitContainers são um ou mais contêineres que são executados antes do contêiner de um aplicativo em um Pod. Os contêineres de inicialização podem conter utilitários ou scripts de configuração não presentes em uma imagem de aplicativo.

Os contêineres de inicialização sempre são executados até a conclusão.
Cada contêiner init deve ser concluído com sucesso antes que o próximo comece.
Se o contêiner init de um Pod falhar, o Kubernetes reiniciará repetidamente o Pod até que o contêiner init tenha êxito. No entanto, se o Pod tiver o restartPolicy como Never, o Kubernetes não reiniciará o Pod, e o contêiner principal não irá ser executado.

Crie o Pod a partir do manifesto:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: init-demo
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
    volumeMounts:
    - name: workdir
      mountPath: /usr/share/nginx/html
  initContainers:
  - name: install
    image: busybox
    command: ['sh', '-c', 'echo The app is running! && sleep 10']
    #command: ['wget','-O','/work-dir/index.html','https://linuxtips.io']
    volumeMounts:
    - name: workdir
      mountPath: "/work-dir"
  dnsPolicy: Default
  volumes:
  - name: workdir
    emptyDir: {}
```

Crie o pod a partir do manifesto.

```
kubectl describe pod init-demo
kubectl logs init-demo -c install

```