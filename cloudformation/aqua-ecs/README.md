[![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?#/stacks/new?stackName=aqua-ecs&templateURL=https://s3.amazonaws.com/aqua-security-public/aquaEcs.yaml)

# Description

This page contains instructions for creating a production-grade deployment of Aqua CSP (Cloud native Security Platform) on an Amazon ECS cluster. 
For high availability, you must deploy Aqua on 2 availability zones (AZs).

These instructions are applicable to all versions of Aqua CSP.

Your deployment will create these services:
 - Aqua Server, deployed with an Amazon Application Load Balancer
 - Aqua Database, created on a new Amazon RDS instance, which includes 7 days of rolling backups
 - Aqua Gateways (2), each on a separate subnet, deployed with a Classic Load Balancer
 - Aqua Enforcers (1 deployed on each host in your cluster, via a DaemonSet)

In addition, it will create an IAM role for giving the Aqua Server access to ECR (Elastic Container Registry).

A CloudFormation template is used to deploy Aqua CSP. This can be done either with the AWS CloudFormation Management Console or the AWS Command Line interface, as explained below.

# Requirements

 - An ECS cluster
 - A VPC with at least 2 subnets connected to the ECS cluster
 - From Aqua Security: your Aqua credentials (username and password) and CSP License Token

# Before deployment

1. Login to the Aqua Registry with your Aqua credentials:
   `docker login registry.aquasec.com -u <AQUA_USERNAME> -p <AQUA_PASSWORD>`
2. Pull the Aqua product images for the Server, Gateway, and Enforcer with these commands. (If you are deploying a version other than 4.0, replace the image tag accordingly.)
   
docker pull registry.aquasec.com/console:4.0
docker pull registry.aquasec.com/gateway:4.0
docker pull registry.aquasec.com/enforcer:4.0
   
3. Push all of the images to ECR.

# Deployment method 1: CloudFormation Management Console

 1. Click the <b>Launch Stack</b> icon at the top of this README.md file. This will take you to the <b>Create stack</b> function of the AWS CloudFormation Management Console.
 2. Ensure that your AWS region is set to where you want to deploy Aqua CSP.
 3. Click "Next".
 4. Set or modify any of the parameters (per the explanations provided).
 5. Click "Next" to create the stack.

It will typically require up to 20 minutes for Aqua CSP to be deployed.
When completed, you can obtain the DNS name of the Aqua Server UI from the console output, under key name `AquaConsole`.

# Deployment method 2: Command Line interface

1. Copy the following command:
```
aws --region us-east-1 cloudformation create-stack --capabilities CAPABILITY_NAMED_IAM --stack-name aqua --template-body file://aquaEcs.yaml \
--parameters ParameterKey=AquaConsoleAccess,ParameterValue=x.x.x.x/x \
ParameterKey=AquaServerImage,ParameterValue=xxxx.dkr.ecr.us-east-1.amazonaws.com/aqua:console-3.5 \
ParameterKey=AquaGatewayImage,ParameterValue=xxxx.dkr.ecr.us-east-1.amazonaws.com/aqua:gateway-3.5 \
ParameterKey=AquaEnforcerImage,ParameterValue=xxxx.dkr.ecr.us-east-1.amazonaws.com/aqua:enforcer-3.5 \
ParameterKey=BatchInstallToken,ParameterValue=someRandHash \
ParameterKey=EcsClusterName,ParameterValue=test \
ParameterKey=EcsInstanceSubnets,ParameterValue=\"subnet-xxxx,subnet-xxxx\" \
ParameterKey=EcsSecurityGroupId,ParameterValue=sg-xxxx \
ParameterKey=MultiAzDatabase,ParameterValue=false \
ParameterKey=RdsInstanceClass,ParameterValue=db.t2.small \
ParameterKey=RdsInstanceName,ParameterValue=aqua \
ParameterKey=RdsMasterPassword,ParameterValue=xxxx \
ParameterKey=RdsMasterUsername,ParameterValue=xxxx \
ParameterKey=RdsStorage,ParameterValue=40 \
ParameterKey=VpcCidr,ParameterValue=x.x.x.x/x \
ParameterKey=VpcId,ParameterValue=vpc-xxxx \
ParameterKey=LbSubnets,ParameterValue=\"subnet-xxxx,subnet-xxx\"
```
2. Set the parameters as follows:
```
AquaConsoleAccess = The IP address or range that may be used to access the Aqua Console (Server UI) (example: x.x.x.x/32)  
AquaServerImage = The ECR path for the Aqua Server product image 
AquaGatewayImage = The ECR path for the Aqua Gateway product image 
AquaEnforcerImage = The ECR path for the Aqua Enforcer product image 
BatchInstallToken = Any string; it will be used as the token in the Aqua Enforcer Install command 
EcsClusterName = Existing ECS cluster name 
EcsInstanceSubnets = Select at least 2 subnets on which you want Aqua to be deployed  
EcsSecurityGroupId = The security group assigned to the ECS cluster during cluster creation 
MultiAzDatabase = Set to true to enable deployment in multiple Availability Zones 
RdsInstanceClass = Set the EC2 instance class for the RDS DB instance 
RdsInstanceName = Set the name of the Aqua DB, e.g., AquaDB 
RdsMasterPassword = The master password for the RDS instance. This password must contain from 8-128 printable ASCII characters except for @, /,  or ". 
RdsMasterUsername = The master username for the RDS instance 
RdsStorage = Set the size (GB) of the RDS DB instance \
VpcCidr = For use by load balancer service polling. Enter the VPC CIDR (example: 10.0.0.0/16) 
VpcId = The VpcId to deploy into 
LbSubnets = Select external subnets  if you need Internet access. 
```
3. Run the AWS create-stack CLI command.

It will typically require up to 20 minutes for your stack to be created and deployed.
When completed, you can obtain the DNS name of the Aqua Server UI from the console output, under key name `AquaConsole`.

# Version upgrade

To upgrade your Aqua CSP version, modify the existing stack with the new Aqua product images.
