REGION=us-east-1
CLUSTERNAME=cluster-01

# Only run this once
eksctl utils associate-iam-oidc-provider --region="$REGION" --cluster="$CLUSTERNAME" --approve 

