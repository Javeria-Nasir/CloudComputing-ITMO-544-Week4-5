#!bin/bash

#set -x

# Name          : Javeria Mohammed Nasir
# Description   : ITM0-544-Week4-Assignment
# Date          : 09/30/2016 
# Parameters    : Please provide ami ID and client token as inputs to the shell script while executing.

# Add if check for param check.
[ $# -eq 0 ] && { echo "Usage: test.sh <ami_id> <client_token>"; exit 1; }

elbName="itmo-544-wk4"
amiID=$1
token=$2

# This function lauch 3 instances in ec2 console.
CreateInstance () {
        echo "Launching Instances..."
        # This command creates 3 instances in us-west-2b
        aws ec2 run-instances --image-id $amiID --key-name jmohamme-eastregion \
--security-group-ids sg-254c995c --client-token $token --instance-type t2.micro \
--user-data file://installapp.sh \
--placement AvailabilityZone=us-west-2b --count 3
}

# This function creates a load balancer and register instances with load balancer.
CreateELB () {
        aws elb create-load-balancer --load-balancer-name $elbName \
--listeners Protocol=Http,LoadBalancerPort=80,InstanceProtocol=Http,InstancePort=80 \
--subnets subnet-9da5e2eb --security-groups sg-254c995c
        echo "Load Balance creation Successfull ! .. "
        aws elb register-instances-with-load-balancer --load-balancer-name $elbName \
--instances $instance_ids
        echo "Instance registration with load balancer successfull."
}

# Calling createInstance function.
CreateInstance

# Listing running instance ids and assigning it to the variable instance-ids
instance_ids=`aws ec2 describe-instances --filters "Name=client-token,Values=$token" --query 'Reservations[*].Instances[].InstanceId'`

# Displaying running instances.
echo "Instance ids : $instance_ids"

# Running wait instance command for instances to come in servie
aws ec2 wait instance-running --instance-ids $instance_ids

# Calling CreateELB function.
CreateELB

# Create launch configuration.
aws autoscaling create-launch-configuration --launch-configuration-name webserverdemo \
--image-id $amiID  --key-name jmohamme-eastregion --instance-type t2.micro \
--user-data file://installapp.sh --security-groups sg-254c995c
echo 'Launch configuration created successfully.'

# Create auto scaling group with min size 1 max size 5 and desired-capacity 1
aws autoscaling create-auto-scaling-group --auto-scaling-group-name mywebserverdemo \
--launch-configuration-name webserverdemo --availability-zones us-west-2b --min-size 0 \
--max-size 5 --desired-capacity 1
echo 'Auto scaling group created successfully.'

# Attaching running instances to auto scaling group.
aws autoscaling attach-instances --instance-ids $instance_ids --auto-scaling-group-name mywebserverdemo
echo 'Instances attached to auto scaling group.'

# Attaching load balancer to auto scaling group.
aws autoscaling attach-load-balancers --load-balancer-names $elbName --auto-scaling-group-name mywebserverdemo
echo 'Load balancer attached to auto-scaling-group.'