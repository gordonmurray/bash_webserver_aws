#!/usr/bin/env bash 

# The following assumes you have an AWS account with the AWS CLI installed locally
# It will ask which VPC and Subnets to use

# Show the commands being executed
set -ex

# AWS region
REGION="eu-west-1"
# Ubuntu Server 18.04 TLS
AMI_ID=02df9ea15c1778c9c
# Instance Type
INSTANCE_TYPE="t2.nano"
# Key Pair name to create
KEY_PAIR_NAME=example
# Security group name
SECURITY_GROUP_NAME=example
# Security group ID
# Leave this value blank as it will be populated later 
SECURITY_GROUP_ID=""
# Subnet ID to use
# Leave this value blank as it will be populated later
SUBNET_ID=""
# VPC ID to use
# Leave this value blank as it will be populated later
VPC_ID=""


#
# Cleaning up
# Only run the following items if you wish to remove the items created above.
#

# List existing VPCs
aws ec2 describe-vpcs --region ${REGION} --query 'Vpcs[*].VpcId'

# Read in the users VPC choice
echo "please chose the VPC to use:"
read VPC_ID

# Get the instance ID of the EC2 instance
INSTANCE_ID=`aws ec2 describe-instances --filter "Name=tag:Name,Values=example" --region eu-west-1 --query 'Reservations[].Instances[].[InstanceId]' --output text`

# delete the EC2 instance
aws ec2 terminate-instances --region ${REGION} --instance-ids ${INSTANCE_ID}

# Sleep to give the instance time to terminate
sleep 60

# Get the security group ID
SECURITY_GROUP_ID=`aws ec2 describe-security-groups --region ${REGION} --filter Name=vpc-id,Values=${VPC_ID} Name=group-name,Values=${SECURITY_GROUP_NAME} --query "SecurityGroups[*].{Name:GroupId}" --output text`

# delete security group
aws ec2 delete-security-group --region ${REGION} --group-id ${SECURITY_GROUP_ID}

# delete the key pair from AWS
aws ec2 delete-key-pair --region ${REGION} --key-name ${KEY_PAIR_NAME}

# delete the key pair from the local folder
rm ${KEY_PAIR_NAME}.pem