#!/usr/bin/env bash 

set -ex

# AWS region
REGION="eu-west-1"
# Key Pair name to use
KEY_PAIR_NAME=example
# Database user password
DATABASE_APPLICATION_USER=website_user
DATABASE_APPLICATION_PASSWORD=""

# Get the instance public DNS name
PUBLIC_DNS=`aws ec2 describe-instances --filter "Name=tag:Name,Values=example" --region ${REGION} --query 'Reservations[].Instances[].[PublicDnsName]' --output text | head -2 | tail -1`

# Set permissions for the pem key
sudo chmod 600 ${KEY_PAIR_NAME}.pem

# Connect to the EC2 instance, update it, install Apache and other items
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ubuntu@${PUBLIC_DNS} -i ${KEY_PAIR_NAME}.pem "sudo apt update && sudo apt install apache2 php php-mysql mysql-server -y"

# Update /var/www/html folder permissions
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ubuntu@${PUBLIC_DNS} -i ${KEY_PAIR_NAME}.pem "sudo chown -R ubuntu:ubuntu /var/www/html"

# remove the default page
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ubuntu@${PUBLIC_DNS} -i ${KEY_PAIR_NAME}.pem "sudo rm -f /var/www/html/index.html"

# Deploy our files
scp -r -i ${KEY_PAIR_NAME}.pem ./src/* ubuntu@${PUBLIC_DNS}:/var/www/html/

# Create the database
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ubuntu@${PUBLIC_DNS} -i ${KEY_PAIR_NAME}.pem "sudo mysql -u root -e \"CREATE DATABASE IF NOT EXISTS website;\""

# Import the table and data
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ubuntu@${PUBLIC_DNS} -i ${KEY_PAIR_NAME}.pem "sudo mysql -u root website < /var/www/html/website.sql"

# Create the database user and permissions
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ubuntu@${PUBLIC_DNS} -i ${KEY_PAIR_NAME}.pem "sudo mysql -u root -e \"CREATE USER IF NOT EXISTS '${DATABASE_APPLICATION_USER}'@'%' IDENTIFIED BY '${DATABASE_APPLICATION_PASSWORD}';\""

# set database user permissions
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ubuntu@${PUBLIC_DNS} -i ${KEY_PAIR_NAME}.pem "sudo mysql -u root -e \"GRANT SELECT, RELOAD, PROCESS, REFERENCES, INDEX, SHOW DATABASES, CREATE TEMPORARY TABLES, LOCK TABLES, SHOW VIEW, EVENT, TRIGGER ON *.* TO '${DATABASE_APPLICATION_USER}'@'%';\""

# flush to make sure changes apply
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ubuntu@${PUBLIC_DNS} -i ${KEY_PAIR_NAME}.pem "sudo mysql -u root -e \"FLUSH PRIVILEGES;\""

# clean up
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ubuntu@${PUBLIC_DNS} -i ${KEY_PAIR_NAME}.pem "sudo rm -f /var/www/html/website.sql"

echo "Server ready"