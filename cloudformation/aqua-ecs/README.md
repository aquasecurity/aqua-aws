# Requirements:  

VPC with 2 subnets.  
ECS cluster.

# Install
Push aquasec-server and aquasec-gateway to ECR.  
Modify parameters and run create-stack:
```
aws --region us-west-2 cloudformation create-stack --capabilities CAPABILITY_NAMED_IAM --stack-name aqua --template-body file://aquaEcs.json \
--parameters ParameterKey=cluster,ParameterValue=test \
ParameterKey=subnets,ParameterValue=\"subnet-xxxx,subnet-xxxx\" \
ParameterKey=vpcId,ParameterValue=vpc-xxxx \
ParameterKey=vpcSubnet,ParameterValue=xxxx \
ParameterKey=aquasecServerImage,ParameterValue=xxxx.dkr.ecr.us-west-2.amazonaws.com/aqua:aquasec-server-3.0 \
ParameterKey=aquasecGatewayImage,ParameterValue=xxxx.dkr.ecr.us-west-2.amazonaws.com/aqua:aquasec-gateway-3.0 \
ParameterKey=dbAllocatedStorage,ParameterValue=40 \
ParameterKey=dbPassword,ParameterValue=xxxx \
ParameterKey=dbUser,ParameterValue=aquaUser \
ParameterKey=multiAzDatabase,ParameterValue=true \
ParameterKey=myDbInstanceClass,ParameterValue=db.m3.medium \
ParameterKey=myDbName,ParameterValue=aqua \
ParameterKey=aquaServerLbSchema,ParameterValue=internet-facing
```


# Screenshots
![Screenshot](cloudformation.png)
