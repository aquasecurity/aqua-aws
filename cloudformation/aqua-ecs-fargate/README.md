[![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?#/stacks/new?stackName=aqua-ecs&templateURL=https://s3.amazonaws.com/aqua-security-public/5.3/aquaFargate.yaml)

# Description

This page contains instructions for creating a deployment of Aqua CSP (Cloud native Security Platform) on an Amazon ECS Fargate cluster. 
For high availability, you must deploy Aqua on 2 availability zones (AZs).

These instructions are applicable to all versions of Aqua CSP.

Your deployment will create these services:
 - Aqua Server, deployed with an Amazon Application Load Balancer
 - Aqua Database, created on a new Amazon RDS instance, which includes 7 days of rolling backups
 - Aqua Audit Database, created on a new Amazon RDS instance, which includes 7 days of rolling backups
 - Aqua Gateways (2), each on a separate subnet, deployed with a Network Load Balancer  

In addition, it will create an IAM role for giving the Aqua Server access to ECR (Elastic Container Registry).

A CloudFormation template is used to deploy Aqua CSP. This can be done either with the AWS CloudFormation Management Console or the AWS Command Line interface, as explained below.

# Requirements
 
 - A VPC with at least 2 subnets 
 - From Aqua Security: your Aqua credentials (username and password) and CSP License Token

# Before deployment

1. Login to the Aqua Registry with your Aqua credentials:
   `docker login registry.aquasec.com -u <AQUA_USERNAME> -p <AQUA_PASSWORD>`
2. Pull the Aqua product images for the Server, Gateway with these commands. 
   ```
   docker pull registry.aquasec.com/console:{version} 
   docker pull registry.aquasec.com/gateway:{version} 
   ```
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
aws --region us-east-1 cloudformation create-stack --capabilities CAPABILITY_NAMED_IAM --stack-name aqua-fargate --template-body file://aquaFargate.yaml \
--parameters ParameterKey=AquaConsoleAccess,ParameterValue=x.x.x.x/x \
ParameterKey=AquaServerImage,ParameterValue=xxxx.dkr.ecr.us-east-1.amazonaws.com/aqua:server-x.x \
ParameterKey=AquaGatewayImage,ParameterValue=xxxx.dkr.ecr.us-east-1.amazonaws.com/aqua:gateway-x.x \
ParameterKey=ClusterName,ParameterValue=xxxx \
ParameterKey=EcsInstanceSubnets,ParameterValue=\"subnet-xxxx,subnet-xxxx\" \
ParameterKey=AuditRdsInstanceClass,ParameterValue=db.t3.medium \
ParameterKey=MultiAzDatabase,ParameterValue=false \
ParameterKey=RdsInstanceClass,ParameterValue=db.t3.medium \
ParameterKey=RdsStorage,ParameterValue=50 \
ParameterKey=VpcCidr,ParameterValue=x.x.x.x/x \
ParameterKey=VpcId,ParameterValue=vpc-xxxx \
ParameterKey=LbSubnets,ParameterValue=\"subnet-xxxx,subnet-xxxx\" \
ParameterKey=LBScheme,ParameterValue=\"internet-facing\" 
ParameterKey=SSLCert,ParameterValue=\"arn:aws:acm:us-east-1:1234567890:certificate/xxxxxxxxxxxx\"
```  
2. Set the parameters as follows:
```
AquaConsoleAccess = The IP address or range that may be used to access the Aqua Console (Server UI) (example: x.x.x.x/32)  
AquaServerImage = The ECR path for the Aqua Server product image 
AquaGatewayImage = The ECR path for the Aqua Gateway product image 
ClusterName = Enter the ECS cluster name to be created
EcsInstanceSubnets = Select at least 2 subnets on which you want Aqua to be deployed   
MultiAzDatabase = Set to true to enable deployment in multiple Availability Zones
AuditRdsInstanceClass = Set the RDS Instance Class for Audit DB
RdsInstanceClass = Set the RDS DB instance class for Aqua Server DB
RdsStorage = Set the size (GB) of the RDS DB instance  
VpcCidr = For use by load balancer service polling. Enter the VPC CIDR (example: 10.0.0.0/16) 
VpcId = The VpcId to deploy into 
LbSubnets = Select external subnets if you need Internet access
LBScheme = Select Internet-facing if you need to access Aqua console from external.
SSLCert = Enter the SSL certificate ARN from Amazon Certificate Manager
```
3. Run the AWS create-stack CLI command.

It will typically require up to 20 minutes for your stack to be created and deployed.
When completed, you can obtain the DNS name of the Aqua Server UI from the console output, under key name `AquaConsole`.

# Active-Active Deployment
For Active-Active configuration we need add the below lines or code in the exisitng aquaFargate.yaml file.

Resources-->AquaConsoleTaskDefinition-->Properties-->ContainerDefinitions-->Secrets

```
- Name: AQUA_PUBSUB_DBPASSWORD
  ValueFrom: !Ref Secret0
- Name: AQUA_PUBSUB_DBUSER
  ValueFrom: !Ref SecretUsername
```			  

Resources-->AquaConsoleTaskDefinition-->Properties-->ContainerDefinitions-->Environment

```
- Name: AQUA_PUBSUB_DBSSL
  Value: require
- Name: AQUA_PUBSUB_DBNAME
  Value: pubsub
- Name: AQUA_PUBSUB_DBHOST
  Value: !GetAtt
    - RdsInstance
    - Endpoint.Address
- NAME: AQUA_CLUSTER_MODE
  VALUE: active-active
 ```

# Version upgrade

To upgrade your Aqua CSP version, modify the existing stack with the new Aqua product images.
