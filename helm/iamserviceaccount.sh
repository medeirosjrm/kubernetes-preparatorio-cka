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

POLICY_ARN=arn:aws:iam::222336856394:policy/NOME-DA-POLICE

eksctl create iamserviceaccount --name $IAMSERVICEACCOUNT_NAME --namespace $NAMESAPCE --region="$REGION" --cluster "$CLUSTERNAME" --attach-policy-arn "$POLICY_ARN" --approve --override-existing-serviceaccounts


