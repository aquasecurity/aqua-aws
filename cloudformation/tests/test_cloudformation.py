import argparse
import logging
import os
# import pytest

# Main
from dep_aws import cloudformation
from dep_aws import boto3

logging.root.setLevel(logging.INFO)
logging.basicConfig(format='%(asctime)s %(levelname)s: %(message)s', datefmt='%m/%d/%Y %I:%M:%S %p')

parser = argparse.ArgumentParser(description='Personal information')
parser.add_argument('--aws_access_key_id', dest='aws_access_key_id', type=str, help='aws_access_key_id', default=os.environ.get("AWS_ACCESS_KEY_ID"))
parser.add_argument('--aws_secret_access_key', dest='aws_secret_access_key', type=str, help='aws_secret_access_key', default=os.environ.get("AWS_SECRET_ACCESS_KEY"))
parser.add_argument('--region', dest='region', type=str, help='region', default=os.environ.get("REGION"))
parser.add_argument('--filename', dest='filename', type=str, help='cloudformation file name')

args = parser.parse_args()

aws_access_key_id = args.aws_access_key_id
aws_secret_access_key = args.aws_secret_access_key
region = args.region
filename = args.filename

if aws_access_key_id is None:
    # logging.error("Missing aws_access_key_id arg, please add it with --aws_access_key_id or with env as: AWS_ACCESS_KEY_ID")
    raise Exception("Missing aws_access_key_id arg, please add it with --aws_access_key_id or with env as: AWS_ACCESS_KEY_ID")
if aws_secret_access_key is None:
    # logging.error("Missing aws_secret_access_key arg, please add it with --aws_secret_access_key or with env as: AWS_SECRET_ACCESS_KEY")
    raise Exception("Missing aws_secret_access_key arg, please add it with --aws_secret_access_key or with env as: AWS_SECRET_ACCESS_KEY")
if region is None:
    # logging.error("Missing region arg, please add it with --region or with env as: REGION")
    raise Exception("Missing region arg, please add it with --region or with env as: REGION")
if filename is None:
    # logging.error("Missing region arg, please add it with --region or with env as: REGION")
    raise Exception("Missing filename arg, please add it with --filename")

logging.info("Succeeded to get cred and region")
session = boto3.Boto3(aws_access_key_id, aws_secret_access_key, region)

ecs_client = session.create_client("ecs")
cf_client = session.create_client("cloudformation")
cf = cloudformation.Cloudformation(cf_client, filename)
cf.verify_cloudformation_template()

# cf.deploy_cloudformation_template()
