First check the aws version

```bash
aws --version
```

- Write your credentials using this command
```bash
aws configure
```

- or Assign a role with AdministratorFullAccess Policy. It is best practice to use IAM role rather than using AWS credentials

1. Create Security Group

```bash
aws ec2 create-security-group \
    --group-name roman_numerals_sec_grp \
    --description "Allow ssh and http from anywhere"
```

- We can check the security group with these command
```bash
aws ec2 describe-security-groups --group-names roman_numerals_sec_grp
```

2. Create inbound rules

```bash
aws ec2 authorize-security-group-ingress \
    --group-name roman_numerals_sec_grp \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-name roman_numerals_sec_grp \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

```

3. After creating security group, We'll create our EC2 which has latest AMI id. To do this, we need to find out latest AMI with AWS system manager (ssm) command

- This command querlies the latest AMI ID
```bash
aws ssm get-parameters --names /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 --query 'Parameters[0].[Value]' --output text
```

- We can assign this latest AMI id output to the LATEST_AMI environmental variable and use in our CLI command 

```
(LATEST_AMI=xxxxxxxxxxxxxxxx)
```
- or we can directly fetch the last version via  using "resolve:ssm". We keep going with using "resolve:ssm" option. 

- in home directory of ec2 create a user-data.sh file with following

```
#! /bin/bash
yum update -y
yum install python3-pip -y
pip3 install Flask
cd /home/ec2-user
wget -P templates https://raw.githubusercontent.com/guile-clarusway/roman/refs/heads/main/templates/index.html
wget -P templates https://raw.githubusercontent.com/guile-clarusway/roman/refs/heads/main/templates/result.html
wget https://raw.githubusercontent.com/guile-clarusway/roman/refs/heads/main/app.py 
python3 app.py
```
- As for the student who use his/her own local terminal, they need to show the absulete path of userdata.sh file

- Now we can run the instance with CLI command. (Do not forget to create user-data.sh under "/home/ec2-user/" folder before run this command)

```bash
aws ec2 run-instances \
    --image-id resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 \
    --count 1 \
    --instance-type t2.micro \
    --key-name guile \
    --security-groups roman_numerals_sec_grp \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=roman_numbers}]'\
    --user-data file://user-data.sh
```
file://home/ec2-user/user-data.sh  for ec2 instance.

- To see the each instances Ip we'll use describe instance CLI command
```bash
aws ec2 describe-instances --filters "Name=tag:Name,Values=roman_numbers"
```

- You can run the query to find Public IP and instance_id of instances:
```bash
aws ec2 describe-instances --filters "Name=tag:Name,Values=roman_numbers" --query 'Reservations[].Instances[].PublicIpAddress[]'

aws ec2 describe-instances --filters "Name=tag:Name,Values=roman_numbers" --query 'Reservations[].Instances[].InstanceId[]'
```

- To delete instances
```bash 
aws ec2 terminate-instances --instance-ids ID_of_the_INSTANCE
```
- To delete security groups
```bash
aws ec2 delete-security-group --group-name roman_numerals_sec_grp
```

AWS CloudFormation CLI Command:

```bash
aws cloudformation create-stack --stack-name guile --template-body file://roman-numerals-template.yaml --parameters ParameterKey=KeyPairParameter,ParameterValue=guile
```