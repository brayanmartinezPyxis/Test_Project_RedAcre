accountId=""

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $accountId.dkr.ecr.us-east-1.amazonaws.com
docker tag backend:latest $accountId.dkr.ecr.us-east-1.amazonaws.com/backend:latest
docker push $accountId.dkr.ecr.us-east-1.amazonaws.com/backend:latest