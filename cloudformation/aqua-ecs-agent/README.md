# Requirements:  

ECS cluster.
Aqua installed.

# Install
Push aquasec-agent to ECR.  
Modify parameters and run create-stack:  

```
aws --region us-east-1 cloudformation create-stack --stack-name aquaAgent --template-body file://aquaAgent.json \
--parameters ParameterKey=cluster,ParameterValue=test \
ParameterKey=aquaToken,ParameterValue=xxxx-xxxx-xxxx-xxxx-xxxx \
ParameterKey=aquaAgentImage,ParameterValue=xxxx.dkr.ecr.us-east-1.amazonaws.com/aqua:aquasec-agent-{version} \
ParameterKey=aquaGatewayAddress,ParameterValue=host:3622
```
