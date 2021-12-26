# Instalar o ESK na AWS


### User Guide Esk Aws
https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html

### EksCtl

https://eksctl.io/


## Passo 1 Configurações no IAM

Criar um usuário
Usuários > Create

Depois em permissions deve-se configurar as seguintes permissões

- AmazonEKSClusterPolicy
- AmazonEKSWorkerNodePolicy
- AmazonEC2ContainerRegistryFullAccess
- AmazonEKSVPCRecourceController
- AmazonS3FullAccess


Depois de criar deve-se copiar o valores de access_key_id e secret_access_key e configurar as credentials dentro da pasta .aws


## Passo 2 Configurar o arquivo de clustes

https://eksctl.io/usage/creating-and-managing-clusters/


```yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: back-office
  region: us-east-2  #Ohaio

nodeGroups:
  - name: bo-node-group-1
    instanceType: m3.small
    desiredCapacity: 2  #capacidade desejada
    volumeSize: 30

  - name: bo-node-group-2
    instanceType: m3.medium
    desiredCapacity: 2 #capacidade desejada
```

```bash
eksctl create cluster -f cluster.yaml
```


## Passo 3 Routes 53  e Policy

Para criar uma nova entrar no DNS como um subdomínio

```bash
aws route53 create-hosted-zone --name "services.nextar.one." --caller-reference "external-dns.test-$(date +%s)"
```

Criar uma police para permitir o k8s gerenciar o registros de DNS no Route53

IAM > Police > JSON 
```json
{
  "Version": "2021-10-17",
  "Statement":[
    {
      "Effect":"Allow",
      "Action":["route53:ChangeResourceRecordSets"],
      "Resource":["arn:aws:route53:::hostedzone/*"],
    },
    {
      "Effect":"Allow",
      "Action":[
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
        ],
      "Resource":["*"],
    },
  ]
}
```

Criar uma IAM Service 

```bash
#opcional Se não tiver um IAM OIDC provides habilitado
eksctl utils associate-iam-oidc-provider --region=us-east-1 --cluster cluester01 --approve

eksctl create iamserviceaccount --name external-dns --namespace default --cluster cluester01 --attach-policy-arn arn:...  --approve


# Para testar se está ok
kubectl get sa   
ou
kubectl get serviceaccounts

kubectl describe sa external-dns
```

## Passo 4 - External DNS


https://peiruwang.medium.com/eks-exposing-service-with-external-dns-3be8facc73b9

Oficial
https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws.md


```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: external-dns
  annotations:
    eks.amazonaws.com/role-arn: arn...
---    
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: external-dns
rules:
- apiGroups: [""]
  resources: ["services","endpoints","pods"]
  verbs: ["get","watch","list"]
- apiGroups: ["extensions", "networking.k8s.oi"]
  resources: ["ingresses"]
  verbs: ["get","watch","list"]
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["list","watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: external-dns-viewer
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: external-dns
subjects:
- kind: ServiceAccount
  name: external-dns
  namespace: kube-system
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: external-dns
  namespace: kube-system
spec:
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: external-dns
  template:
    metadata:
      labels:
        app: external-dns
      # If you're using kiam or kube2iam, specify the following annotation.
      # Otherwise, you may safely omit it
      # annotations:
      #   iam.amazonaws.com/role: arn...
    spec:
      serviceAccountName: external-dns
      containers:
      - name: external-dns
        image: registry.opensource.zalan.do/teapot/external-dns:latest
        args:
        - --source=service
        - --source=ingress
        - --domain-filter=external-dns-test.my-org.com # will make ExternalDNS see only the hosted zones matching provided domain, omit to process all available hosted zones
        - --provider=aws
        - --policy=upsert-only # would prevent ExternalDNS from deleting any records, omit to enable full synchronization
        - --aws-zone-type=public # only look at public hosted zones (valid values are public, private or no value for both)
        - --registry=txt
        - --txt-owner-id=my-hostedzone-identifier #ID so route 53
      securityContext:
        fsGroup: 65534 # For ExternalDNS to be able to read Kubernetes and AWS token filesLoadBalancer 

```

```bash
kubectl create -f external-dns.yaml

kubectl get deploy
kubectl get pods
kubectl logs -f external-pod-name
```



Configurando o cert-manager e testando o external-dns 
https://school.linuxtips.io/courses/1259521/lectures/36215277



## Passo 4 - Cert manager

https://cert-manager.io/docs/installation/helm/

```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update

#kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.6.1/cert-manager.crds.yaml

helm upgrade \
  cert-manager jetstack/cert-manager \
  --install \
  --namespace cert-manager \
  --create-namespace \
  --values "cert-manager-values.yaml" --wait
```

```yaml
serviceAccount: 
  annotations:
    eks.amazonaws.com/role-arn: arn...

installCRDS: true

secyrityContext:
  enabled: true
  fsGroup: 1001
```



