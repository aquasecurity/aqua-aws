# Terraform Aqua Security Build

- [Goals](#goals)
- [Prerequisites](#prerequisites)
- [AWS Preparation](#aws-preparation)
    - [Domain Name](#domain-name)
    - [Secrets](#secrets)
    - [S3 Bucket](#s3-bucket)
    - [EC2 Key Pair](#ec2-key-pair)
- [Template Preparation](#template-preparation)
    - [Variables and Files](#variable-and-files)
- [Terraform Version](#terraform-version)
- [Gotchas](#gotchas)
    - [AWS Managed Role](#aws-managed-role)
    - [AWS Service Limits](#aws-service-limits)
    - [Unsupported Instance Configuration](#unsupported-instance-configuration)
- [Running the Template Step-by-Step](#running-the-template-step-by-step)
- [Cleaning Up](#cleaning-up)
- [Special Thanks](#special-thanks)


# Goals

The main goal of this project is templatize a production ready Aqua Security build on AWS using Terraform using [AWS ECS](https://aws.amazon.com/ecs/) (Elastic Container Service). While this template will likely require ongoing opitmizations, the end goal is to standardize a production level deployment on AWS for folks that just don't have the time and resources to start from scratch.

Since multi-AWS accounts are being used more and more (hint: they should be), this template is currently configured to support multi-AWS account scanning for [AWS ECR](https://aws.amazon.com/ecr/) (Elastic Container Registry). For example, instead of using AWS access keys (which require periodic rotation) in other AWS accounts for ECR scanning, cross account IAM roles can be used instead.

# Prerequisites

Before you can use this template, you'll need to have a few things in place:

1. Login credentials to [https://my.aquasec.com](https://my.aquasec.com) so that you can download your license key and Aqua CSP containers. If you do not have this information, contact your Aqua Security account manager.

2. A domain name registered and a hosted zone configured in AWS Route 53. You can purchase a domain name using AWS Route 53 or use a domain name that you've previously registered with another domain registrar. Below is an example of what this should look like in your AWS Route 53 console for a hosted zone:

<p align="center">
<img src="https://github.com/jeremyjturner/terraform-aqua-csp/blob/master/images/01-route53-domain-name-example.jpg" alt="Example of having a Route 53 domain name configured." height="75%" width="75%">
</p>

3. Terraform installed on the computer that will execute this template. This template was created with Terraform version `v0.11.13`. If you are new to Terraform, check out [Terraform Switcher](https://warrensbox.github.io/terraform-switcher/) to help you get started.

4. The AWS CLI configured on the computer that will deploy this template with Terraform.

# AWS Preparation

## Domain Name

As mentioned in the [Prerequisites](#prerequisites) section above, you'll need a domain name. You can easily [create and buy a domain name using Route 53](https://aws.amazon.com/getting-started/tutorials/get-a-domain/) or you can add a domain name that you own to Route 53.

For this project, I've taken a spare domain name that I own called `securitynoodles.com` and created a Route 53 hosted zone. Note the nameservers (NS) highlighted in red:

<p align="center">
<img src="https://github.com/jeremyjturner/terraform-aqua-csp/blob/master/images/02-route53-created-hosted-zone-example.jpg" alt="Example of having a Route 53 hosted zone configured." height="75%" width="75%">
</p>

This domain was registered with [Hover](hover.com) so all I have to do is edit the nameservers for `securitynoodles.com` in my Hover management console:

<p align="center">
<img src="https://github.com/jeremyjturner/terraform-aqua-csp/blob/master/images/03-add-route53-ns-to-domain-registrar.jpg" alt="Example of updating domain registrar Nameservers with Route 53 Nameservers" height="75%" width="75%">
</p>

## Secrets

 Since we need to work with passwords and login credentials, we'll need to have various secrets stored in AWS Secrets Manager. Some of these secrets such as the Aqua Security login credentials will need to be provided to by Aqua Security so as mentioned in the [Prerequisites](#prerequisites) section, make sure to contact your account manager if you don't have them. This template will use the default AWS managed `aws/ssm` KMS key and should be sufficient for most environments. The secrets that you need to prepare are:

- Username and Password for your Aqua Security account
- Your Aqua License Token
- A password for the Aqua CSP web console
- A password for your Aqua RDS PostgreSQL database

Here are some AWS CLI commands to help you set up these secrets. You are welcome to use the AWS Console but since you'll be working from the command line anyway, it might make sense to use the reference commands below. If this is the first time for you to setup anything in Secrets Manager, use the values for `--name` and `--description` unless you know exactly what you want:

```
aws secretsmanager create-secret --region <<YOUR_TARGET_AWS_REGION>> --name aqua/container_repository \
--description "Username and Password for the Aqua Container Repository" \
--secret-string "{\"username\":\"<<YOUR_AQUA_USERNAME>>\",\"password\":\"<<YOUR_AQUA_PASSWORD>>\"}"
 
aws secretsmanager tag-resource --region <<YOUR_TARGET_AWS_REGION>> --secret-id aqua/container_repository \
    --tags "[{\"Key\": \"Owner\", \"Value\": \"<<YOUR_NAME>>\"}]"
  
aws secretsmanager create-secret --region <<YOUR_TARGET_AWS_REGION>> --name "aqua/admin_password" \
    --description "Aqua CSP Console Administrator Password" \
    --secret-string "<<ADMIN_PASSWORD>>"
 
aws secretsmanager tag-resource --region <<YOUR_TARGET_AWS_REGION>> --secret-id aqua/admin_password \
    --tags "[{\"Key\": \"Owner\", \"Value\": \"<<YOUR_NAME>>\"}]"
 
aws secretsmanager create-secret --region <<YOUR_TARGET_AWS_REGION>> --name "aqua/license_token" \
    --description "Aqua Security License" \
    --secret-string "<<LICENSE_TOKEN>>"
 
aws secretsmanager tag-resource --region <<YOUR_TARGET_AWS_REGION>> --secret-id aqua/license_token \
    --tags "[{\"Key\": \"Owner\", \"Value\": \"<<YOUR_NAME>>\"}]"
  
aws secretsmanager create-secret --region <<YOUR_TARGET_AWS_REGION>> --name "aqua/db_password" \
    --description "Aqua CSP Database Password" \
    --secret-string "<<YOUR_DB_PASSWORD>>"
 
aws secretsmanager tag-resource --region <<YOUR_TARGET_AWS_REGION>> --secret-id aqua/db_password \
    --tags "[{\"Key\": \"Owner\", \"Value\": \"<<YOUR_NAME>>\"}]"
```

If you opted to run the commands above instead of using the AWS Console, make sure to clear the commands that contain secrets out of your bash history with the following command:

`history -d <line number to destroy>`

Also, if you copy and paste these commands, make sure that you are performing those actions in plaintext since some characters can become incorrectly formatted and insert incorrect values into your AWS SSM store. A good example of this is quote marks: `”` and `"`

Whatever method you use to setup your secrets, you should have something similar to the screenshot below:

<p align="center">
<img src="https://github.com/jeremyjturner/terraform-aqua-csp/blob/master/images/04-aws-secrets-manager-prepared-example.jpg" alt="Example of having secrets stored in AWS SSM." height="75%" width="75%">
</p>

## S3 Bucket

Next, you'll need an S3 bucket to store your terraform state. Remember that AWS S3 bucket names are global so you have to use unique bucket names. In other words, the bucket name I'm using in the example below will not work for you.

Using the administrator user `aquacsp` that I've configured in my AWS account, I've created the bucket `jturner-terraform-state` in the Tokyo region using the AWS CLI:

```
jeremyturner: aws --profile aquacsp s3 mb s3://jturner-terraform-state --region ap-northeast-1
make_bucket: jturner-terraform-state
```

Use the following command to list the contents–at this point the S3 bucket should be empty:

```
jeremyturner: aws --profile aquacsp s3 ls s3://jturner-terraform-state
jeremyturner:
```
Put the bucket name that you created in the file `aquacsp-infrastructure.config`. For my example, the contents of `aquacsp-infrastructure.config` will look like this when I use the Tokyo (ap-northeast-1) region:

```
key="aquacsp/aquacsp-infrastructure.tfstate"
bucket="jturner-terraform-state"
region="ap-northeast-1"

```

## EC2 Key Pair

You will also need to have an EC2 Key Pair configured so that you can launch instances for ECS. Don't forget to set the file permission on the private key with `chmod 400 <private key file name>`. The name of this key pair will be configured in the `terraform.tfvars` file for the variable `ssh-key_name`. In my case, I created a key pair and it's saved locally as `aquacsp-test-tokyo.pem` in my cloned `terraform-aqua-csp` folder. Therefore, my `ssh-key-name` variable will look like this:

```
ssh-key-name = aquacsp-test-tokyo
```
Don't include the file extension `.pem`. Otherwise, you'll get the error:

`ValidationError: The key pair 'your-key-name.pem' does not exist`

# Template Preparation

## Variables and Files

First, clone this repo and `cd` into the cloned directory `terraform-aqua-csp`:

```
jeremyturner: git clone git@github.com:jeremyjturner/terraform-aqua-csp.git
Cloning into 'terraform-aqua-csp'...
remote: Enumerating objects: 43, done.
remote: Counting objects: 100% (43/43), done.
remote: Compressing objects: 100% (35/35), done.
remote: Total 43 (delta 5), reused 39 (delta 5), pack-reused 0
Receiving objects: 100% (43/43), 157.45 KiB | 318.00 KiB/s, done.
Resolving deltas: 100% (5/5), done.
jeremyturner: cd terraform-aqua-csp/
```

Variables are located in the file `variables.tf` and you'll enter ***your*** values in the file `terraform.tfvars`.

Don't forget to enter ***your*** own values in the file `aquacsp-infrastructure.config` as mentioned in the [S3 Bucket](#s3-bucket) section above.

Next, using the instructions in section [EC2 Key Pair](#ec2-key-pair), copy over your EC2 Key Pair into the `terraform-aqua-csp` directory. In the example below, I have copied over `aquacsp-test-tokyo.pem`:

```
jeremyturner: ls -lah
total 216
drwxr-xr-x  29 jeremyturner  staff   928B Aug 15 20:51 .
drwxr-xr-x   4 jeremyturner  staff   128B Aug 15 20:51 ..
drwxr-xr-x  12 jeremyturner  staff   384B Aug 15 20:49 .git
-rw-r--r--   1 jeremyturner  staff    32B Aug 15 20:49 .gitignore
-rw-r--r--   1 jeremyturner  staff   1.0K Aug 15 20:49 LICENSE
-rw-r--r--   1 jeremyturner  staff    12K Aug 15 20:49 README.md
-rw-r--r--   1 jeremyturner  staff   1.4K Aug 15 20:49 alb.tf
-rw-r--r--   1 jeremyturner  staff   136B Aug 15 20:49 aquacsp-infrastructure.config
-r--------@  1 jeremyturner  staff   1.7K Aug 14 11:34 aquacsp-test-tokyo.pem
-rw-r--r--   1 jeremyturner  staff   2.2K Aug 15 20:49 asg.tf
-rw-r--r--   1 jeremyturner  staff   2.0K Aug 15 20:49 cross_acct_ecr_iam.tf
-rw-r--r--   1 jeremyturner  staff   395B Aug 15 20:49 cwl.tf
-rw-r--r--   1 jeremyturner  staff   1.4K Aug 15 20:49 dns.tf
-rw-r--r--   1 jeremyturner  staff   3.6K Aug 15 20:49 ecs.tf
-rw-r--r--   1 jeremyturner  staff   990B Aug 15 20:49 elb.tf
-rw-r--r--   1 jeremyturner  staff   4.7K Aug 15 20:49 iam.tf
drwxr-xr-x   6 jeremyturner  staff   192B Aug 15 20:49 images
-rw-r--r--   1 jeremyturner  staff     1B Aug 15 20:49 main.tf
-rw-r--r--   1 jeremyturner  staff   248B Aug 15 20:49 outputs.tf
-rw-r--r--   1 jeremyturner  staff    79B Aug 15 20:49 provider.tf
-rw-r--r--   1 jeremyturner  staff   1.5K Aug 15 20:49 rds.tf
-rw-r--r--   1 jeremyturner  staff   1.1K Aug 15 20:49 secrets_manager.tf
-rw-r--r--   1 jeremyturner  staff   4.1K Aug 15 20:49 security_group.tf
-rw-r--r--   1 jeremyturner  staff   410B Aug 15 20:49 target_group.tf
drwxr-xr-x   4 jeremyturner  staff   128B Aug 15 20:49 task-definitions
-rw-r--r--   1 jeremyturner  staff   2.6K Aug 15 20:49 terraform.tfvars
drwxr-xr-x   3 jeremyturner  staff    96B Aug 15 20:49 userdata
-rw-r--r--   1 jeremyturner  staff   2.8K Aug 15 20:49 variables.tf
-rw-r--r--   1 jeremyturner  staff   373B Aug 15 20:49 vpc.tf
```

Now input your values in the `terraform.tfvars` file. Here is an example snippet of my values–note that I've left the variable`aqua_console_access` open to `0.0.0.0/0` since I'm only testing that my Terraform template works:

```
#################################################
# Aqua CSP Project - INPUT REQUIRED
#################################################
region = "ap-northeast-1"
resource_owner = "Jeremy Turner"
project = "aquacsp"

#################################################
# DNS Configuration - INPUT REQUIRED
# You must have already configured a domain name
# and hosted Zone in Route 53 for this to work!!!
#################################################
dns_domain= "securitynoodles.com"
console_name = "aqua"

###################################################
# Security Group Configuration - INPUT REQUIRED
# Avoid leaving the Aqua CSP open to the world!!!
###################################################
aqua_console_access = "0.0.0.0/0"
<snip>
<snip>
#################################################
# EC2 Configuration - INPUT REQUIRED
#################################################
ssh-key_name = "aquacsp-test-tokyo"
instance_type = "m5.large"
<snip>
```
Make sure to configure your `aquacsp-infrastructure.config` file as mentioned previously. Here is my configuration:

```
key="aquacsp/aquacsp-infrastructure.tfstate"
bucket="jturner-terraform-state"
region="ap-northeast-1"
```
Now we need to make sure you have the correct version of Terraform. Since I'm using [Terraform Switcher](https://warrensbox.github.io/terraform-switcher/), I'll simply run `tfswitch` and pick version `0.11.13`:

```
jeremyturner: tfswitch 
✔ 0.11.13 *recent
Switched terraform to version "0.11.13"
```

# Terraform Version

As mentioned before, this template was run using Terraform `v0.11.13`. This is an important distinction because different Terraform versions do not play well together.

# Gotchas

## AWS Managed Role

There is a huge gotcha that you should know about before running this template. For whatever reason, the AWS managed role called `AWSServiceRoleForECS` doesn't exist until you create an ECS cluster in the AWS console or manually create it from the CLI:

```
jeremyturner: aws --profile aquacsp iam get-role --role-name AWSServiceRoleForECS --region ap-northeast-1

An error occurred (NoSuchEntity) when calling the GetRole operation: The role with name AWSServiceRoleForECS cannot be found.
```

Here are the commands to create the role and check that it exists–note that I have snipped out some of the output for brevity:

```
jeremyturner: aws --profile aquacsp iam create-service-linked-role --aws-service-name ecs.amazonaws.com
{
    "Role": {
        "Path": "/aws-service-role/ecs.amazonaws.com/",
        "RoleName": "AWSServiceRoleForECS",
 <snip>
 <snip>       
    }
}
jeremyturner: aws --profile aquacsp iam get-role --role-name AWSServiceRoleForECS --region ap-northeast-1
{
    "Role": {
        "Path": "/aws-service-role/ecs.amazonaws.com/",
        "RoleName": "AWSServiceRoleForECS",
        "RoleId": "AROAWAHJUXLUVPOGNQMJH",
        "Arn": "arn:aws:iam::XXXXXXXXXX:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS",
        "CreateDate": "2019-08-15T14:25:23Z",
<snip>
<snip>
        "MaxSessionDuration": 3600
    }
}
```
Feel free to read the information from AWS called [Using Service-Linked Roles for Amazon ECS](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using-service-linked-roles.html) to learn more about this behaviour.

## AWS Service Limits

This often gets overlooked until it's too late but AWS won't let you create anything you want. This template makes uses of `m5.large` instances but some AWS accounts might have a quoto of zero for this size. Make sure to check out your service limits because this will prevent this template from working. Below is screenshot from AWS CloudTrail showing that the `RunInstances` **Event name** has an **Error code** of *Client.InstanceLimitExceeded*:

<p align="center">
<img src="https://github.com/jeremyjturner/terraform-aqua-csp/blob/master/images/05-service-limits-exceeded-example.jpg" alt="Example of Exceeding AWS Service Limits." height="75%" width="75%">
</p>

## Unsupported Instance Configuration

This one is a bit tricky because as long as you haven't reached your service limits, you'd assume that you can launch any instance type that is supported by the ECS ami. This is not true and if you try to use an instance such as m3.large, you'll get an **Error code** of *Client.Unsupported* in CloudTrail:

<p align="center">
<img src="https://github.com/jeremyjturner/terraform-aqua-csp/blob/master/images/06-unsupported-client-example.jpg" alt="Example of an unsupported ECS instance configuration." height="75%" width="75%">
</p>

Feel free to dig deeper into these messages using the CloudTrail console or the AWS CLI. Here is an AWS CLi command (make sure to replace or remove the `--profile` portion for your command) to help you get started looking for these type of errors but feel free to reference the [lookup-events](https://docs.aws.amazon.com/cli/latest/reference/cloudtrail/lookup-events.html) AWS CLI documentation:

```
aws --profile aquacsp cloudtrail lookup-events --lookup-attributes AttributeKey=EventName,AttributeValue=RunInstances --query 'Events[0:5]|[?contains(CloudTrailEvent, `errorCode`) == `true`]|[?contains(CloudTrailEvent, `errorMessage`) == `true`].[CloudTrailEvent]' --output text
```

# Running the Template Step-by-Step

At this point, you've completed the steps at [AWS Preparation](#aws-preparation) and [Template Preparation](#template-preparation). Now it's time to do the Terraform stuff.

Since I've created the AWS CLI profile `aquacsp`, which maps to an administrator user called `aquacsp` in my AWS account, I'm going to need Terraform to run commands on that profile. I'll solve that problem by exporting my AWS CLI profile to the variable `AWS_PROFILE`:

```
jeremyturner: export AWS_PROFILE=aquacsp
jeremyturner: echo $AWS_PROFILE
aquacsp
```

Note that in your environment, you'll probably have a different process. For example, some shops use a tool called [saml2aws](https://github.com/Versent/saml2aws) with an identity provider such as [JumpCloud](https://jumpcloud.com/) because they have multple AWS accounts running production services.

Now that you have your AWS profile configured, run the following `init` command. Note that I have snipped out much of the output for brevity:

```
jeremyturner: terraform init -backend-config="aquacsp-infrastructure.config"
Initializing modules...
- module.asg
  Found version 2.11.0 of terraform-aws-modules/autoscaling/aws on registry.terraform.io
  Getting source "terraform-aws-modules/autoscaling/aws"
- module.db
  Found version 1.31.0 of terraform-aws-modules/rds/aws on registry.terraform.io
  Getting source "terraform-aws-modules/rds/aws"
<snip>

Initializing the backend...

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

<snip>

Terraform has been successfully initialized!

<snip>
```

Now run the `plan` command:

```
jeremyturner: terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

data.template_file.userdata: Refreshing state...
data.aws_kms_alias.secretsmanager: Refreshing state...
data.aws_secretsmanager_secret.admin_password: Refreshing state...
<snip>
<snip>
Plan: 64 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------
```

And now it's time for the moment of truth...run the `apply` command:

```
jeremyturner: terraform apply
data.template_file.userdata: Refreshing state...
data.aws_iam_role.service_role-ecs-service: Refreshing state...
data.aws_secretsmanager_secret.db_password: Refreshing state...
data.aws_kms_alias.secretsmanager: Refreshing state...
<snip>
<snip>
Plan: 64 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_cloudwatch_log_group.aquacsp-vpc: Creating...
<snip>
<snip>
Apply complete! Resources: 64 added, 0 changed, 0 destroyed.

Outputs:

alb_dns_name = aquacsp-alb-1763586840.ap-northeast-1.elb.amazonaws.com
elb_dns_name = internal-aquacsp-aqua-gw-elb-926191805.ap-northeast-1.elb.amazonaws.com
hostnames = [
    aqua.securitynoodles.com
]
```
While the things are spinning up, head over to your CloudWatch Log Groups and search for the `/ecs/aquacsp/` group. Here you can see your logs for the console and gateway in case something doesn't go as expected:

<p align="center">
<img src="https://github.com/jeremyjturner/terraform-aqua-csp/blob/master/images/07-aws-cloudwatch-log-group-example.jpg" alt="Example of Finding CloudWatch Logs for Aqua CSP." height="75%" width="75%">
</p>

Your console should be accessible by whatever FQDN you configured. In my example `aqua.securitynoodles.com`:

<p align="center">
<img src="https://github.com/jeremyjturner/terraform-aqua-csp/blob/master/images/08-aqua-csp-login-screen-example.jpg" alt="Example of Aqua CSP Login Screen." height="75%" width="75%">
</p>

Login using the administrator password you set and stored in AWS Secrets manager. After logging in, make sure that the Aqua Gateway is connected:

<p align="center">
<img src="https://github.com/jeremyjturner/terraform-aqua-csp/blob/master/images/09-aqua-csp-gw-connected-example.jpg" alt="Example of Aqua CSP Gateway successfully connected." height="75%" width="75%">
</p>

# Cleaning Up

Once you've tested everything, make sure to clean-up the resources your made. Otherwise, you'll be footing the bill for some beefy instances.

Run `destroy` to delete all of the resources:

```
jeremyturner: terraform destroy
data.template_file.userdata: Refreshing state...
aws_cloudwatch_log_group.ecs: Refreshing state... (ID: /ecs/aquacsp)
aws_acm_certificate.cert: Refreshing state... (ID: arn:aws:acm:ap-northeast-1:412806855401...e/154cbd10-c475-4901-9225-d84ab8ced0fd)
<snip>
<snip>
<snip>
  - module.db.module.db_subnet_group.aws_db_subnet_group.this


Plan: 0 to add, 0 to change, 64 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes
<snip>
<snip>
<snip>
module.vpc.aws_vpc.this: Destroying... (ID: vpc-0fa3e733df9438cd4)
module.vpc.aws_vpc.this: Destruction complete after 0s

Destroy complete! Resources: 64 destroyed.
jeremyturner: 
```
Finally, note that the VPC log group `/vpc/aquacsp` doesn't get destroyed so you'll need to manually delete it. For more context on this behaviour check out [VPC Flow Logs](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html#flow-logs-iam) which states that you need to delete from the AWS console or CLI.

# Special Thanks

Special thanks to 加藤 諒 and his article (In Japanese) [「Aqua Container Security Platform」を立ててみた（本番環境用編）](https://dev.classmethod.jp/cloud/aws/aqua_server_on_aws_ecs/) and the source he released at [https://github.com/kmd2kmd/aqua_csp-on-aws_ecs](https://github.com/kmd2kmd/aqua_csp-on-aws_ecs) to inspire me to make my own template.