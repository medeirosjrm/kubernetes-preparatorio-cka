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

```
aws eks --region us-east-1 update-kubeconfig --name nome-do-cluster
```

