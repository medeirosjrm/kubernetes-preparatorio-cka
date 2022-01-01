# Ingress

## O que é o Ingress

Normalmente quando executamos um Pod no Kubernetes, todo o tráfego é roteado somente pela rede do cluster, e todo tráfego externo acaba sendo descartado ou encaminhado para outro local. Um ingress é um conjunto de regras para permitir que as conexões externas de entrada atinjam os serviços dentro do cluster

Vamos criar nosso primeiro Ingress, mas primeiro vamos gerar dois deployments e dois services:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app1
spec:
  replicas: 2
  selector:
    matchLabels:
      app: app1
  template:
    metadata:
      labels:
        app: app1
    spec:
      containers:
      - image: dockersamples/static-site
        name: app1
        env:
        - name: AUTHOR
          value: GIROPOPS
        ports:
        - containerPort: 80

```

Config map
```bash
kubectl create configmap cmap-app1 --from-file index.html=index-app1.html 
kubectl create configmap cmap-app2 --from-file index.html=index-app2.html 
#kubectl create configmap apps-configmap --from-file app1=index-app1.html --from-file app2=index-app2.html
```

Atenção para os seguintes parâmetros no arquivo anterior:

terminationGracePeriodSeconds => Tempo em segundos que ele irá aguardar o pod ser finalizado com o sinal SIGTERM, antes de realizar a finalização forçada com o sinal de SIGKILL.
livenessProbe => Verifica se o pod continua em execução, caso não esteja, o kubelet irá remover o contêiner e iniciará outro em seu lugar.
readnessProbe => Verifica se o container está pronto para receber requisições vindas do service.
initialDelaySeconds => Diz ao kubelet quantos segundos ele deverá aguardar para realizar a execução da primeira checagem da livenessProbe
timeoutSeconds => Tempo em segundos que será considerado o timeout da execução da probe, o valor padrão é 1.
periodSeconds => Determina de quanto em quanto tempo será realizada a verificação do livenessProbe.

```bash
kubectl create namespace ingress

namespace/ingress created

```
Crie o deployment do backend no namespace ingress:
```
kubectl create -f default-backend.yaml -n ingress 

deployment.apps/default-backend created
```

Crie um arquivo para definir um service para o backend:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: default-backend
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8080
  selector:
    app: default-backend
```


Crie o service para o backend no namespace ingress:
```bash
kubectl create -f default-backend-service.yaml -n ingress 

service/default-backend created
```

## Configurações do ingress

Agora crie o um arquivo para definir um configMap a ser utilizado pela nossa aplicação:
```bash
vim nginx-ingress-controller-config-map.yaml
```

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-ingress-controller-conf
  labels:
    app: nginx-ingress-lb
data:
  enable-vts-status: 'true'
```
Crie o configMap no namespace ingress:
```bash
kubectl create -f nginx-ingress-controller-config-map.yaml -n ingress

configmap/nginx-ingress-controller-conf created


kubectl get configmaps -n ingress


vim nginx-ingress-controller-service-account.yaml
```

Vamos criar os arquivos para definir as permissões para o nosso deployment:
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: nginx
  namespace: ingress
```

```bash
vim nginx-ingress-controller-clusterrole.yaml
```

```yaml
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: nginx-role
rules:
- apiGroups:
  - ""
  - "extensions"
  resources:
  - configmaps
  - secrets
  - endpoints
  - ingresses
  - nodes
  - pods
  verbs:
  - list
  - watch
- apiGroups:
  - ""
  resources:
  - services
  verbs:
  - list
  - watch
  - get
  - update
- apiGroups:
  - "extensions"
  resources:
  - ingresses
  verbs:
  - get
- apiGroups:
  - ""
  resources:
  - events
  verbs:
  - create
- apiGroups:
  - "extensions"
  resources:
  - ingresses/status
  verbs:
  - update
- apiGroups:
  - ""
  resources:
  - configmaps
  verbs:
  - get
  - create
```

ingress 03