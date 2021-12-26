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
