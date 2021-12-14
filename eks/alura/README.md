# Instalar o ESK na AWS


### User Guide Esk Aws
https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html


## Passo 1 Instalações

Instalar o aws cli

```
https://docs.aws.amazon.com/pt_br/cli/latest/userguide/install-cliv2.html
```

Instalar o kubectl

```
https://kubernetes.io/docs/tasks/tools/
```

O que usar na AWS

- CloudFormation
- EKS
- EC2

<br>

## Passo 2 - IAM

1. Role 
2. Create Role 
3. Na lista de serviços que vai aparecer na próxima tela criar escolher ESK 
4. next
5. next
6. Informar o nome da role
7. Create

<br>

## Passo 3 - VPC

VPC é uma rede virtual criada dentro da AWS, a VPC é criada por região

Vamos usar o CloudFormation para criar as configurações da VPC

1. Acessar o CloudFormation 
2. Create Stack
3. Choose a template > Specify an Amazon S3 template url 
4. Specify Details > Name > VPC-esk > NEXT
5. NEXT
6. Create


<br>

## Passo 4 - Criar o ESK

Comando para criar o cluster

--name = nome do cluster
--role-arn = no IAM > Roles >ESK (nome da role ) > Summary > Role arn

--resources-vpc-config = Pegar os ids das subnets configurações da subnet > aws > vpcs > subnets > subnet ID

securityGroupIds = Pegar os ids dos security groupds é aws > vpcs > security group > procurar o SG criado para o ESK e pegar o security group Id
```
aws eks create-cluster --name producao --role-arn ARN_DA_ROLE_AQUI --resources-vpc-config subnetIds=SUBNET_ID_1_AQUI,SUBNET_ID_2_AQUI,SUBNET_ID_3_AQUI,securityGroupIds=SECURITY_GROUP_DA_VPC_AQUI
```

Ver os cluster criados
```
aws eks list-clusters
aws eks describe-cluster --name NOME_DO_CLUSTER
aws eks describe-cluster --name NOME_DO_CLUSTER | grep status
```

## Passo 5 - Configurar o Kubectl / KubeConfi

Opção 1:
```
aws eks --region us-east-1 update-kubeconfig --name nome-do-cluster
```

Opção 2:
```
curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/linux/amd64/aws-iam-authenticator

chmod +x aws-iam-authenticator

mv aws-iam-authenticator ~/.local/bin

aws eks update-kubeconfig --name producao
```

# Passo 6 - Criar nodes 

1. Acessar o CloudFormation 
2. Create Stack
3. Choose a template > Specify an Amazon S3 template url > amazon-eks-nodegroup.yaml
4. Specify Details > Stacl Name > Produção
    1. ClusterName = nome do cluster
    2. Cluster Control Panel Security Group = Procurar o VPC criado anteriormente
    3. Nome Group name = Producao
    4. Node Auto Scaling Group Min Size = 1  (minimo)
    5. Node Auto Scaling Group Desired Capacity = 2 (desejado)
    6. Node Auto Scaling Group Max Size = 4 (máximo)
    7. Node Instance Type = t3.small (t3.medium)
    8. Node Image ID = Ver link abaixo (Lista de imagems) 
    9. Node Volume Size = 20 (gb)
    10. Key Name = Selecionar a chave ssh
    11. Worker Network configuration
        1. VpcID = Selecionar a vpc criada anteriormente
        2. Subnets = Selecionar todas as subnets criadas anteriormente
5. NEXT
6. Create

Lista de Imagems 
```
https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html
```

## Menu EC2 

1. Verificar se todas as intâncias foram criadas
2. Veificar no menu Auto Scale > Launch Config 
3. Auto Scaling Group - Define as configurações e aplica as configurações de auto scaling


# Passo 7 - Adicionar os nós ao cluster

Para adicionar os nós ao cluster vamos baixar o mapa de configurações

https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html

rolearn = CloudFormation > Node Stack (nome da stack) > Outupu > NodeInstanceRole | Value


```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: <ARN of instance role (not instance profile)>
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
```

Exemplo de aplicação
https://github.com/ricardomerces/guestbook-app
