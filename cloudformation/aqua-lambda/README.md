[![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?#/stacks/new?stackName=aqua-ecs&templateURL=https://s3.amazonaws.com/aqua-security-public/aquaServerless.yaml)

# Description

This page contains instructions for creating a deployment of Aqua Serverless audit stack on an Amazon account. 

These instructions are applicable to version 5.0 and above of Aqua CSP.

Your deployment will create these services:
 - SQS - to collect the audit events from Aqua Nano-Enforcers.
 - Lambda function to handle and send to Aqua gateway the generated audit events.

A CloudFormation template is used to deploy Aqua serverless audit stack. This can be done either with the AWS CloudFormation Management Console or the AWS Command Line interface, as explained below.

# Requirements

 - From Aqua Security: the zip file of Aqua audit handle Lambda function, you should store it in your S3.

# Before deployment

1. Make sure you upload Aqua audit function to your S3.

# Deployment method 1: CloudFormation Management Console

 1. Click the <b>Launch Stack</b> icon at the top of this README.md file. This will take you to the <b>Create stack</b> function of the AWS CloudFormation Management Console.
 2. Ensure that your AWS region is set to where you want to deploy Aqua CSP.
 3. Click "Next".
 4. Set or modify any of the parameters (per the explanations provided).
 5. Click "Next" to create the stack.

It will typically require up to 20 minutes for Aqua CSP to be deployed.
When completed, you can obtain the generated `AQUA_SQS_URL` from the outputs tab, under key name `aquaSQSUrl`.

# Deployment method 2: Command Line interface

1. Copy the following command:
```
aws --region us-east-1 cloudformation create-stack --capabilities CAPABILITY_NAMED_IAM --stack-name aqua-serverless-audit --template-body file://aquaServerless.yaml \
--parameters ParameterKey=AquaGatewayAddress,ParameterValue=x.x.x.x:3622 \
ParameterKey=AquaToken,ParameterValue=xxxx \
ParameterKey=S3Bucket ,ParameterValue=xxxx \ 
ParameterKey=S3CodeKey,ParameterValue=xxxx \
```
3. Run the AWS create-stack CLI command.

It will typically require up to 20 minutes for your stack to be created and deployed.
When completed, you can obtain the `AQUA_SQS_URL` from the console output, under key name `aquaSQSUrl`.

# Version upgrade

To upgrade your stack, modify the existing stack with the new configuration.

