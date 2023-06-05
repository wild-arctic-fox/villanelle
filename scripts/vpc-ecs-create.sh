#!/bin/bash

# Create VPC
vpc_id=$(aws ec2 create-vpc --tag-specification "ResourceType=vpc,Tags=[{Key=Name,Value=CliVpc}]" --cidr-block 10.0.0.0/16 --instance-tenancy default --amazon-provided-ipv6-cidr-block --query 'Vpc.VpcId' --output text)

# Create Subnet 1
subnet1_id=$(aws ec2 create-subnet --vpc-id $vpc_id --availability-zone eu-central-1a --cidr-block 10.0.1.0/24 --query 'Subnet.SubnetId' --output text)

# Create Subnet 2
subnet2_id=$(aws ec2 create-subnet --vpc-id $vpc_id --availability-zone eu-central-1b --cidr-block 10.0.2.0/24 --query 'Subnet.SubnetId' --output text)

# Create Security Group
security_group_id=$(aws ec2 create-security-group --group-name sg --description "sg" --vpc-id $vpc_id --query 'GroupId' --output text)

# Authorize Security Group Ingress (Custom Port 7410)
aws ec2 authorize-security-group-ingress --group-id $security_group_id --protocol tcp --port 7410 --cidr 0.0.0.0/0

# Create Internet Gateway
gateway_id=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text)

# Attach Internet Gateway to VPC
aws ec2 attach-internet-gateway --vpc-id $vpc_id --internet-gateway-id $gateway_id

# Create Route Table
route_table_id=$(aws ec2 create-route-table --vpc-id $vpc_id --query 'RouteTable.RouteTableId' --output text)

# Create Route (IPv4)
aws ec2 create-route --route-table-id $route_table_id --destination-cidr-block 0.0.0.0/0 --gateway-id $gateway_id

# Associate Subnet 1 with Route Table
aws ec2 associate-route-table --route-table-id $route_table_id --subnet-id $subnet1_id

# Associate Subnet 2 with Route Table
aws ec2 associate-route-table --route-table-id $route_table_id --subnet-id $subnet2_id

echo "VPC ID: $vpc_id"
echo "Subnet 1 ID: $subnet1_id"
echo "Subnet 2 ID: $subnet2_id"
echo "Security Group ID: $security_group_id"
echo "Internet Gateway ID: $gateway_id"
echo "Route Table ID: $route_table_id"

# Create ECS Cluster
cluster_arn=$(aws ecs create-cluster --cluster-name app_cluster --query 'cluster.clusterArn' --output text)

# Create ECS Task Definition
task_definition_arn=$(aws ecs register-task-definition --family appl --requires-compatibilities FARGATE --cpu 256 --memory 512 --network-mode awsvpc --task-role-arn arn:aws:iam::$1:role/ecsTaskExecutionRole --execution-role-arn arn:aws:iam::$1:role/ecsTaskExecutionRole --container-definitions '[
    {
      "name": "appl",
      "image": "$1.dkr.ecr.eu-central-1.amazonaws.com/patrick-jane-repo:v1.1.0",
      "cpu": 256,
      "memory": 512,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 7410,
          "hostPort": 7410
        }
      ]
    }
]' --query 'taskDefinition.taskDefinitionArn' --output text)

# Create ECS Service
service_name="app_service"
desired_count=1
aws ecs create-service --cluster $cluster_arn \
    --service-name $service_name \
    --task-definition $task_definition_arn \
    --launch-type FARGATE \
    --desired-count $desired_count \
    --deployment-configuration "maximumPercent=200,minimumHealthyPercent=100" \
    --network-configuration "awsvpcConfiguration={subnets=[$subnet1_id,$subnet2_id],securityGroups=[$security_group_id],assignPublicIp=ENABLED}"

echo "ECS Cluster ARN: $cluster_arn"
echo "ECS Task Definition ARN: $task_definition_arn"
echo "ECS Service Name: $service_name"
echo "Desired Count: $desired_count"
