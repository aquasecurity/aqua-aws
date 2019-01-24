# Requirements:  

VPC with 2 subnets.  
ECS host security group.  

# Install
Push server and gateway to ECR.  
Modify parameters and run create-stack:

```
aws --region us-east-1 cloudformation create-stack --capabilities CAPABILITY_NAMED_IAM --stack-name aqua-fargate --template-body file://aquaFargate.yaml \
--parameters ParameterKey=AquaConsoleAccess,ParameterValue=x.x.x.x/x \
ParameterKey=AquaServerImage,ParameterValue=xxxx.dkr.ecr.us-east-1.amazonaws.com/aqua:server-3.5 \
ParameterKey=AquaGatewayImage,ParameterValue=xxxx.dkr.ecr.us-east-1.amazonaws.com/aqua:gateway-3.5 \
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
ParameterKey=Region,ParameterValue=us-east-1 \
ParameterKey=LbSubnets,ParameterValue=\"subnet-xxxx,subnet-xxxx\"
```
