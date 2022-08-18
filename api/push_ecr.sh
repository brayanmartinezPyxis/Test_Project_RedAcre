aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 753941739980.dkr.ecr.us-east-1.amazonaws.com
docker tag backend:latest 753941739980.dkr.ecr.us-east-1.amazonaws.com/backend:latest
docker push 753941739980.dkr.ecr.us-east-1.amazonaws.com/backend:latest