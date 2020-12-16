<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" />

# Aqua Security AWS Deployments

This repository is for [Aqua Security](https://www.aquasec.com) deployments related to [Amazon Web Services (AWS)](https://aws.amazon.com/).

## Navigation and description

* **ECS CloudFormation** - [*Aqua Security ECS deployment*](https://github.com/aquasecurity/aqua-aws/tree/master/cloudformation/aqua-ecs): Instructions for creating a production-grade deployment of Aqua Enterprise (Server, Gateway, and Aqua Enforcer) on an Amazon ECS cluster, using either a CloudFormation temploate or a command line interface
* **ECS Terraform** - [*Aqua Security ECS deployment*](https://github.com/aquasecurity/aqua-aws/tree/master/terraform): As above, using [Terraform](https://www.terraform.io/)
* **ECS Fargate** - [*Aqua Security ECS Fargate deployment*](https://github.com/aquasecurity/aqua-aws/tree/master/cloudformation/aqua-ecs-fargate): Instructions for creating a production-grade deployment of Aqua Enterprise (Server and Gateway) on an Amazon ECS Fargate cluster
* **Enforcer** - [*Aqua Security ECS Agent*](https://github.com/aquasecurity/aqua-aws/tree/master/cloudformation/aqua-ecs-agent): Deploy an Aqua Enforcer as a DaemonSet on an existing ECS cluster
* **Serverless** - [*Aqua Security Serverless*](https://github.com/aquasecurity/aqua-aws/tree/master/cloudformation/aqua-lambda): Deploy the Aqua audit handler stack with SQS, to handle audit events reported by Aqua NanoEnforcers (for function runtime enforcement)