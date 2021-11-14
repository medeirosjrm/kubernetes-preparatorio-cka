# HELM

## Instalações

- AWS CLI
  - https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

- eksctl 
  - https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html

- kubectl
  - https://kubernetes.io/docs/tasks/tools/install-kubectl-macos/

- helm
  - https://helm.sh/docs/intro/install/


- Ativar o k8s
  - aws eks --region us-east-1 update-kubeconfig --name cluster-01

- K8sLens
  - https://k8slens.dev/



## Configurações básicas

As duas principais configurações são o service.yaml e o deployment.yaml eles fazer com que o um pod suba no k8s e seja exporto para o mundo exterior, criando um Deployment, um ReplicaSet, os pods, endpoints e o service com o load balance


## Como é um service?

```yaml
apiVersion: v1
kind: Service
metadata:
  name: app-service
  namespace: ns-da-aplicacao
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: http
    service.beta.kubernetes.io/aws-load-balancer-ssl-ports: "443"
    service.beta.kubernetes.io/aws-load-balancer-ssl-cert: "arn:aws:-do-certificado-para-https"

spec:
  type: LoadBalancer
  selector:
    app: meu-app-k8s
  ports:
    - name: http
      protocol: TCP
      port: 80
      targetPort: 80
    - name: https
      protocol: TCP
      port: 443
      targetPort: 80
```

## Como é um deployment?

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: meu-app-deployment
  namespace: ns-da-aplicacao
  labels:
    app: meu-app-k8s
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: meu-app-k8s
  template:
    metadata:
      labels:
        app: meu-app-k8s
    spec:
      serviceAccountName: nome-da-conta-de-servico-criada-pelo-eksctl-create-iamserviceaccount 
      # Containers
      #----------------
      containers:
        - name: meu-app-k8s
          image: url-do-container-registry:{{ .Values.versao }}          
          imagePullPolicy: Always
          ports:
            - containerPort: 80
          env:
            - name: AMBIENTE
              value: {{ .Values.ambiente }}
          volumeMounts:
          ## K8s Configs Maps
            - name: vol-configmap
              mountPath: /app/config/app.config
              subPath: app.config
              readOnly: true
          ## K8s Secrets
            - name: vol-secrets
              mountPath: /app/config/database.config
              subPath: database.config
              readOnly: true
          ## Aws Secrets Manager          
            - name: vol-secrets-manager
              mountPath: /app/config/aws_secret.config
              subPath: aws_secret.config
              readOnly: true
            
          readinessProbe:
            httpGet:
              path: /api/health
              port: 80
            initialDelaySeconds: 10
            periodSeconds: 5
            successThreshold: 1
      # Volumes
      #----------------
      volumes:
        # K8s ConfigMap
        - name: vol-configmap
          configMap:
            name: {{ .Values.ambiente }}-meu-configmap      
        # K8s Secrets
        - name: vol-secrets
          secret:
            secretName: {{ .Values.ambiente }}-secrets-name
        # Aws - Secrets Manager
        - name: vol-secrets-manager
          csi:
            driver: secrets-store.csi.k8s.io
            readOnly: true
            volumeAttributes:
              secretProviderClass: nome-do-secret-provider-class


# Se for necessário definir afinidade para os pods sejam distribuidos pelo menos um por nó
#      nodeSelector:
#        role: webservices

      # affinity:
      #   #Nao deixar 2 pods no mesmo node
      #   podAntiAffinity:
      #     requiredDuringSchedulingIgnoredDuringExecution:
      #       - labelSelector:
      #           matchExpressions:
      #             - key: app
      #               operator: In
      #               values:
      #                 - contas-php
      #         topologyKey: "kubernetes.io/hostname"
```

## Como é um ConfigMap?

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Values.ambiente }}-meu-configmap
  namespace: ns-da-aplicacao
data:
  app.config: |
    {{- tpl ((.Files.Glob "qa/config/app.config").AsConfig) . | nindent 2 }}
```

## Como é um Secret?

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: {{ .Values.ambiente }}-meu-secrets
  namespace: ns-da-aplicacao
stringData:
  database.config: |
    {{- tpl ((.Files.Glob "qa/secrets/database.config").AsConfig) . | nindent 2 }}  

```

## AWS - ESK - Pré requisitos

### Instalações

```
AWS CLI
https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html

eksctl 
https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html

kubectl
https://kubernetes.io/docs/tasks/tools/install-kubectl-macos/

helm
https://helm.sh/docs/intro/install/


Ativar o k8s
aws eks --region us-east-1 update-kubeconfig --name cluster-01

K8sLens
https://k8slens.dev/

Para configurar as métricas no lens, entrar em settings do cluster > Metrics > Prometheus Service Address : prometheus/prometheus-server:80
```


## Como integrar e configurar o k8s com AWS Secret Manager ?


### Documentação
```
Usar segredos do Secrets Manager no Amazon Elastic Kubernetes Service
https://docs.aws.amazon.com/pt_br/secretsmanager/latest/userguide/integrating_csi_driver.html

Tutorial: Criar e montar um segredo em um pod do Amazon EKS
https://docs.aws.amazon.com/pt_br/secretsmanager/latest/userguide/integrating_csi_driver_tutorial.html

Create an IAM OIDC provider for your cluster
https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html

Exemplo SecretProviderClass
https://github.com/aws/secrets-store-csi-driver-provider-aws/tree/main/examples

```

### Primeiros passos 

No tutorial https://docs.aws.amazon.com/pt_br/secretsmanager/latest/userguide/integrating_csi_driver.html realizar os passos 1 e 2
- 1 Instalar o drive CSI

```
helm repo add secrets-store-csi-driver https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/master/charts
helm install -n kube-system csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver
```

- 2 Instalar o provider da aws
```
kubectl apply -f https://raw.githubusercontent.com/aws/secrets-store-csi-driver-provider-aws/main/deployment/aws-provider-installer.yaml
```

### Criar um IAM OIDC (Apenas se não tiver sido criado ainda)

https://docs.aws.amazon.com/pt_br/secretsmanager/latest/userguide/integrating_csi_driver_tutorial.html

```bash
REGION=us-east-1
CLUSTERNAME=cluster-01

# Only run this once
eksctl utils associate-iam-oidc-provider --region="$REGION" --cluster="$CLUSTERNAME" --approve 

```

### Criar um secret via linha de comando

https://docs.aws.amazon.com/pt_br/secretsmanager/latest/userguide/integrating_csi_driver_tutorial.html


```bash
REGION=us-east-1
CLUSTERNAME=cluster-01

aws --region "$REGION" secretsmanager  create-secret --name MySecret --secret-string '{"username":"lijuan", "password":"hunter2"}'

```

### Criar uma police e uma IAM Service Account

https://docs.aws.amazon.com/pt_br/secretsmanager/latest/userguide/integrating_csi_driver_tutorial.html

**Opção 1**: Criar e vincular a police

```bash
REGION=us-east-1
CLUSTERNAME=cluster-01
NAMESAPCE=ns-app
IAMSERVICEACCOUNT_NAME=nome-da-conta
POLICE_NAME=NOME-DA-POLICE

CREATED_POLICY_ARN=$(aws --region "$REGION" --query Policy.Arn --output text iam create-policy --policy-name $POLICE_NAME --policy-document '{
    "Version": "2012-10-17",
    "Statement": [ {
        "Effect": "Allow",
        "Action": ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"],
        "Resource": ["arn:aws:secretsmanager:us-east-1:<CODIGO_CONTA>:secret:*"]
    } ]
}')

eksctl create iamserviceaccount --name $IAMSERVICEACCOUNT_NAME --namespace $NAMESAPCE --region="$REGION" --cluster "$CLUSTERNAME" --attach-policy-arn "$CREATED_POLICY_ARN" --approve --override-existing-serviceaccounts

```

**Opção 2**: Apenas vincular a police

```bash
REGION=us-east-1
CLUSTERNAME=cluster-01
NAMESAPCE=ns-app
IAMSERVICEACCOUNT_NAME=nome-da-conta
POLICE_NAME=NOME-DA-POLICE
POLICY_ARN=arn:-da-police

eksctl create iamserviceaccount --name $IAMSERVICEACCOUNT_NAME --namespace $NAMESAPCE --region="$REGION" --cluster "$CLUSTERNAME" --attach-policy-arn "$POLICY_ARN" --approve --override-existing-serviceaccounts

```


## Como configurar o Helm para usar o AWS Secret Manager?

- Criar o yaml do ServiceAccount.

**OBS:** Depois de  executar o comando eksctl create iamserviceaccount será necessário pegar o ARN do service account dentro do console da IAM > Roles > EKS...alguma coia (ps. ele gera com um nome padrão )
```yaml
# Quando utilizar um Service account para conexão com o AWS Secret Manager deve-se configurar essa estrutura

apiVersion: v1
kind: ServiceAccount
metadata:
  name: nome-da-conta-de-servico-criada-pelo-eksctl-create-iamserviceaccount 
  namespace: ns-da-aplicacao
  annotations:    
    eks.amazonaws.com/role-arn: arn:-da-role-no-IAM

```

- Criar o yaml para o SecretProviderClass

```yaml
apiVersion: secrets-store.csi.x-k8s.io/v1alpha1
kind: SecretProviderClass
metadata:
  name: nome-do-secret-provider-class
  namespace: ns-da-aplicacao
spec:
  provider: aws
  parameters:
    objects: |
      - objectName: "arn:aws:secretsmanager:-Objeto-no-aws-secret-manager"
        objectAlias: "aws_secret.ini"

```

- Para finalizar dentro do nosso arquivo de deployment é necessário configurar 3 propriedades
   - volumes > csi
   - volumeMounts
   - serviceAccountName (Esse diz qual a conta de serviço o pod utilizará para conectar com o Aws SecretManager)


```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: meu-app-deployment
  namespace: ns-da-aplicacao
  labels:
    app: meu-app-k8s
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: meu-app-k8s
  template:
    metadata:
      labels:
        app: meu-app-k8s
    spec:
      serviceAccountName: nome-da-conta-de-servico-criada-pelo-eksctl-create-iamserviceaccount 
      # Containers
      #----------------
      containers:
        - ...
          volumeMounts:
          ## Aws Secrets Manager          
            - name: vol-secrets-manager
              mountPath: /app/config/aws_secret.config
              subPath: aws_secret.config
              readOnly: true
      # Volumes
      #----------------
      volumes:
        # Aws - Secrets Manager
        - name: vol-secrets-manager
          csi:
            driver: secrets-store.csi.k8s.io
            readOnly: true
            volumeAttributes:
              secretProviderClass: nome-do-secret-provider-class

```



## Entrar em um pod

```
kubectl exec -it -n backoffice contas-php-5877cf9477-8jh68 -c contas-php bash

```

## Criar e excluir um configMap

```
kubectl create configmap -n backoffice contas-dev-database.ini --from-file=database.ini

kubectl delete configmap contas-dev

```


