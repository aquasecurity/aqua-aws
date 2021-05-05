[![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?#/stacks/new?stackName=aqua-ecs&templateURL=https://s3.amazonaws.com/aqua-security-public/5.3/aquaEcs.yaml)

# Description

This page contains instructions for creating a deployment of Aqua Enterprise on an Amazon ECS EC2 cluster. It will deploy all Aqua Enterprise components in one ECS cluster with advanced configurations like a separate DB for Audit, SSL enablement for the Aqua console, and active-active Server mode. 
 
For high availability, you must deploy Aqua on 2 availability zones (AZs).

These instructions are applicable to all versions of Aqua Enterprise.

Your deployment will create these services:
 - Aqua Server, deployed with an Amazon Application Load Balancer
 - Aqua Database, created on a new Amazon RDS instance, which includes 7 days of rolling backups
 - Aqua Audit Database, created on a new Amazon RDS instance, which includes 7 days of rolling backups
 - Aqua Gateways (2), each on a separate subnet, deployed with a Network Load Balancer
 - Aqua Enforcer, each on an ECS instance

In addition, it will create an IAM role for giving the Aqua Server access to ECR (Elastic Container Registry).

A CloudFormation template is used to deploy Aqua Enterprise. This can be done either with the AWS CloudFormation Management Console or the AWS Command Line interface, as explained below.

## Requirements

 - An ECS cluster with at least 2 instances registered
 - A VPC with at least 2 subnets
 - From Aqua Security: your Aqua credentials (username and password) and Enterprise License Token

## Before deployment

1. Login to the Aqua Registry with your Aqua credentials:
   `docker login registry.aquasec.com -u <AQUA_USERNAME> -p <AQUA_PASSWORD>`
2. Pull the Aqua product images for the Server (Console), Gateway and Aqua Enforcer with these commands. 
   ```
   docker pull registry.aquasec.com/console:{version} 
   docker pull registry.aquasec.com/gateway:{version}
   docker pull registry.aquasec.com/enforcer:{version}
   ```
3. Push all of the images to ECR.

## Deployment method 1: CloudFormation Management Console

 1. Click the <b>Launch Stack</b> icon at the top of this README.md file. This will take you to the <b>Create stack</b> function of the AWS CloudFormation Management Console.
 2. Ensure that your AWS region is set to where you want to deploy Aqua Enterprise.
 3. Click "Next".
 4. Set or modify any of the parameters (per the explanations provided).
 5. Click "Next" to create the stack.

It will typically require up to 20 minutes for Aqua Enterprise to be deployed.
When completed, you can obtain the DNS name of the Aqua Server UI from the console output, under key name `AquaConsole`.

## Deployment method 2: command line interface

1. Copy the following command:
```
aws --region us-east-1 cloudformation create-stack --capabilities CAPABILITY_NAMED_IAM --stack-name aqua-ec2 --template-body file://aquaEcs.yaml \
--parameters ParameterKey=ECSClusterName,ParameterValue=xxxxx \
ParameterKey=VpcId,ParameterValue=vpc-xxxx \
ParameterKey=VpcCidr,ParameterValue=x.x.x.x/x \
ParameterKey=EcsInstanceSubnets,ParameterValue=\"subnet-xxxx,subnet-xxxx\" \
ParameterKey=LbSubnets,ParameterValue=\"subnet-xxxx,subnet-xxxx\" \
ParameterKey=SSLCert,ParameterValue=\"arn:aws:acm:us-east-1:1234567890:certificate/xxxxxxxxxxxx\"
ParameterKey=LBScheme,ParameterValue=\"internet-facing\"
ParameterKey=AquaConsoleAccess,ParameterValue=x.x.x.x/x \
ParameterKey=AquaServerImage,ParameterValue=xxxx.dkr.ecr.us-east-1.amazonaws.com/aqua:server-x.x \
ParameterKey=AquaGatewayImage,ParameterValue=xxxx.dkr.ecr.us-east-1.amazonaws.com/aqua:gateway-x.x \
ParameterKey=AquaEnforcerImage,ParameterValue=xxxx.dkr.ecr.us-east-1.amazonaws.com/aqua:enforcer-x.x \
ParameterKey=BatchinstallToken,ParameterValue=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxx \
ParameterKey=RdsInstanceClass,ParameterValue=db.t3.medium \
ParameterKey=RdsStorage,ParameterValue=50 \
ParameterKey=MultiAzDatabase,ParameterValue=false \
ParameterKey=AuditRdsInstanceClass,ParameterValue=db.t3.medium \ 
ParameterKey=EcsSecurityGroupId,ParameterValue=XXXXX \ 
ParameterKey=ActiveActive,ParameterValue=XXXXX \ 
```  
2. Set the parameters as follows:
```
ECSClusterName = The existing ECS cluster name and make sure the cluster must have two ec2 instances.
VpcId = The VpcId to deploy into. Select the same VpcId where the ECS Cluster has deployed.
VpcCidr = For use by load balancer service polling. Enter the VPC CIDR (example: 10.0.0.0/16)
EcsInstanceSubnets = Select at least 2 subnets from VPC on which you want to deploy Aqua.
LbSubnets = Subnets for LB. Select External/Public subnets if you want to access Aqua from Internet.
SSLCert = Enter the SSL certificate ARN from Amazon Certificate Manager.
LBScheme = Select Internet-facing if you need to access Aqua console from external.
AquaConsoleAccess = The IP address or range that may be used to access the Aqua Console (Server UI) (example: x.x.x.x/32)  
AquaServerImage = The ECR path for the Aqua Server product image 
AquaGatewayImage = The ECR path for the Aqua Gateway product image 
AquaEnforcerImage = The ECR path for the Aqua Enforcer product image
BatchinstallToken = The Aqua Token, enter any value in the  form of alpha-numeric (example: 6589db6a-1ee5-43d1-a06a-14a6abc38c2b). Once after the deployment, you need to approve the enforcers from Aqua console in default enforcer group then you can move them in to your own enforcer group.
RdsInstanceClass = Set the RDS DB instance class for Aqua Server DB 
RdsStorage = Set the size (GB) of the RDS DB instance
MultiAzDatabase = Set to true to enable deployment in multiple Availability Zones
AuditRdsInstanceClass = Set the RDS Instance Class for Audit DB
EcsSecurityGroupId = Select the security group ID which is same as ECS cluster security group ID or ECS Cluster Instances security group ID.
ActiveActive = Set to true for aqua console active active configuration 
```
3. Run the AWS create-stack CLI command.

It will typically require up to 20 minutes for your stack to be created and deployed.
When completed, you can obtain the DNS name of the Aqua Server UI from the console output, under key name `AquaConsole`.

## Active-active Server deployment

For an active-active Server configuration select the ActiveActive parameter value as true.

## Split DB deployment

Having a seprate DB for audit events is an optional parameter. Select Yes for AuditRDS parameter if you would like to create a separate RDS instance otherwise select No to use single RDS instance both. Default value for AuditRDS (or split DB) is No. 

# Version upgrade

To upgrade your Aqua Enterprise version, modify the existing stack with the new Aqua product images.

# Enforcer-only deployment

[![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?#/stacks/new?stackName=aqua-ecs&templateURL=https://s3.amazonaws.com/aqua-security-public/5.3/aquaEnforcer.yaml)

## Description

The Aqua Server and Gateway are deployed on a given ECS EC2 cluster. In multi-cluster environments, you can deploy Aqua Enforcers on different clusters.

## Requirements

 - One or more ECS clusters
 - Aqua Gateway (existing) service DNS/IP
 - From Aqua Security: your Aqua credentials (username and password) and Aqua Enterprise License Token
 - Aqua Token
 
## Before deployment

1. Login to the Aqua Registry with your Aqua credentials:
   `docker login registry.aquasec.com -u <AQUA_USERNAME> -p <AQUA_PASSWORD>`
2. Pull the Aqua Enforcer image. 
   ```
   docker pull registry.aquasec.com/enforcer:{version}
   ```
3. Push enforcer image to ECR.

## Deployment method 1: CloudFormation Management Console

 1. Click the <b>Launch Stack</b> icon at the top of this README.md file. This will take you to the <b>Create stack</b> function of the AWS CloudFormation Management Console.
 2. Ensure that your AWS region is set to where you want to deploy Aqua Enterprise.
 3. Click "Next".
 4. Set or modify any of the parameters (per the explanations provided).
 5. Click "Next" to create the stack.
 
## Deployment method 2: Command Line interface

1. Copy the following command:
```

aws --region us-east-1 cloudformation create-stack --capabilities CAPABILITY_NAMED_IAM --stack-name aqua-ec2 --template-body file://aquaEnforcer.yaml \
--parameters ParameterKey=AquaGatewayAddress,ParameterValue=xxxxx \
ParameterKey=AquaToken,ParameterValue=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxx \
ParameterKey=AquaEnforcerImage,ParameterValue=xxxx.dkr.ecr.us-east-1.amazonaws.com/aqua:enforcer-x.x\
ParameterKey=ECSClusterName,ParameterValue=xxxxx
```

2. Set the parameters as follows:
```

AquaGatewayAddress = The Gateway Service DNS name or IP address (IP address with port number)
AquaToken = Token from existing Aqua Enforcer group of the Aqua Server
AquaEnforcerImage = The ECR path for the Aqua Enforcer product image
ECSClusterName = The existing ECS cluster name

```
3. Run the AWS create-stack CLI command.

It will deploy Aqua Enforcer in your desired cluster and the newly deployed enforcers will get add to the existing Aqua server.

# Scanner-only Deployment. 

[![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?#/stacks/new?stackName=aqua-ecs&templateURL=https://s3.amazonaws.com/aqua-security-public/5.3/aquaScanner.yaml)

## Description

This will help you to deploy Aqua in multi-cluster, you can deploy scanner in any other ECS EC2 cluster from Aqua (Server & Gateway) deployed clusters.

Requirements

 - An ECS cluster(s)
 - Aqua Server DNS/IP
 - From Aqua Security: your Aqua credentials (username and password) and CSP License Token
 - Aqua Scanner User Name and Password
 
## Before deployment

1. Login to the Aqua Registry with your Aqua credentials:
   `docker login registry.aquasec.com -u <AQUA_USERNAME> -p <AQUA_PASSWORD>`
2. Pull the Aqua Scanner image. 
   ```
   docker pull registry.aquasec.com/scanner:{version}
   ```
3. Push scanner image to ECR.

## Deployment method 1: CloudFormation Management Console

 1. Click the <b>Launch Stack</b> icon at the top of this README.md file. This will take you to the <b>Create stack</b> function of the AWS CloudFormation Management Console.
 2. Ensure that your AWS region is set to where you want to deploy Aqua Scanner.
 3. Click "Next".
 4. Set or modify any of the parameters (per the explanations provided).
 5. Click "Next" to create the stack.
 
## Deployment method 2: Command Line interface

1. Copy the following command:
```

aws --region us-east-1 cloudformation create-stack --capabilities CAPABILITY_NAMED_IAM --stack-name aqua-scanner --template-body file://aquaScanner.yaml \
--parameters ParameterKey=AquaServerAddress,ParameterValue=xxxxx \
ParameterKey=AquaScannerUserName,ParameterValue=xxxxx \
ParameterKey=AquaScannerPassword,ParameterValue=xxxxx \
ParameterKey=AquaScannerImage,ParameterValue=xxxx.dkr.ecr.us-east-1.amazonaws.com/aqua:scanner-x.x\
ParameterKey=ECSClusterName,ParameterValue=xxxxx
```

2. Set the parameters as follows:
```

AquaServerAddress = The Server DNS name or IP address (IP address with port number)
AquaScannerUserName = The Scanner user name from Aqua server
AquaScannerPassword = The Scanner user Password
AquaScannerImage = The ECR path for the Aqua Scanner product image
ECSClusterName = The existing ECS cluster name

```
3. Run the AWS create-stack CLI command.

It will deploy Aqua Scanner in your desired cluster and the newly deployed scanner will get add to the existing Aqua server.
