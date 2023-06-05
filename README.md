### Build docker container 
```docker build -t patrick-jane .```
### Run docker container 
```docker run -p7410:7410 --name pj-container patrick-jane:latest```

### Create aws ECR Manually

### Create Policy 
```sh scripts/aws-ecr-policy-user-create.bash <account-id>```

### Create .env file with aws secrets 

### Create Github secrets
```sh scripts/github-add-secrets.bash```

### Create VPC & ECS Cluster & Sevice
```sh scripts/vpc-ecs-create.sh <account-id>``
