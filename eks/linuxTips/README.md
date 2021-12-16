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


## Passo 3 Routes 53 -  DNS External

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
#opcional
eksctl utils associate-iam-oidc-provider --region=us-east-1 --cluster cluester01 --approve

eksctl create iamserviceaccount --name external-dns --namespace default --cluster cluester01 --attach-policy-arn arn:...  --approve
```

13:45


