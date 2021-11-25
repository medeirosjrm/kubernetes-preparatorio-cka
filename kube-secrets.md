# Secrets

Objetos do tipo Secret são normalmente utilizados para armazenar informações confidenciais, como por exemplo tokens e chaves SSH. Deixar senhas e informações confidenciais em arquivo texto não é um bom comportamento visto do olhar de segurança. Colocar essas informações em um objeto Secret permite que o administrador tenha mais controle sobre eles reduzindo assim o risco de exposição acidental.

Vamos criar nosso primeiro objeto Secret utilizando o arquivo secret.txt que vamos criar logo a seguir.

```
echo -n "giropops strigus girus" > secret.txt

kubectl create secret generic my-secret --from-file=secret.txt
secret/my-secret created


kubectl describe secret my-secret
kubectl get secret

kubectl get secret my-secret -o yaml

echo 'Z2lyb3BvcHMgc3RyaWd1cyBnaXJ1cw==' | base64 --decode

```

## Exemplo de pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-secret
  namespace: default
spec:
  containers:
  - image: busybox
    name: busy
    command:
      - sleep
      - "3600"
    volumeMounts:
    - mountPath: /tmp/giropops
      name: my-volume-secret
  volumes:
  - name: my-volume-secret
    secret:
      secretName: my-secret
```

```
kubectl create -f pod-secret.yaml
kubectl exec -ti test-secret -- ls /tmp/giropops
kubectl exec -ti test-secret -- cat /tmp/giropops/secret.txt
```

## Criando um secret literal

```
kubectl create secret generic my-literal-secret --from-literal user=linuxtips --from-literal password=catota


kubectl describe secret my-literal-secret
```

## Jogando os valores do secret como variáveis de ambiente do pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: teste-secret-env
  namespace: default
spec:
  containers:
  - image: busybox
    name: busy-secret-env
    command:
      - sleep
      - "3600"
    env:
    - name: MEU_USERNAME
      valueFrom:
        secretKeyRef:
          name: my-literal-secret
          key: user
    - name: MEU_PASSWORD
      valueFrom:
        secretKeyRef:
          name: my-literal-secret
          key: password
```

```
kubectl create -f pod-secret-env.yaml
...

kubectl exec teste-secret-env -c busy-secret-env -it -- printenv
...
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=teste-secret-env
TERM=xterm
MEU_USERNAME=linuxtips
MEU_PASSWORD=catota
KUBERNETES_SERVICE_PORT=443
KUBERNETES_SERVICE_PORT_HTTPS=443
KUBERNETES_PORT=tcp://10.96.0.1:443
KUBERNETES_PORT_443_TCP=tcp://10.96.0.1:443
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_PORT_443_TCP_PORT=443
KUBERNETES_PORT_443_TCP_ADDR=10.96.0.1
KUBERNETES_SERVICE_HOST=10.96.0.1
HOME=/root
```