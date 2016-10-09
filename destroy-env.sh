#!/bin/bash

#Retrieving instances lauched using client-token by passing client-token value passed for runing create-env.sh script.
instance_id=`aws ec2 describe-instances --filters "Name=client-token,Values=$1" --query 'Reservations[*].Instances[].InstanceId'`

#printing the running instance id's
echo "Instance IDs : $instance_id"

#Detach load balancer from the autoscaling group
aws autoscaling detach-load-balancers --load-balancer-names itmo-544-wk4 --auto-scaling-group-name mywebserverdemo
echo 'Load balancer detached successfully from the auto scaling group.'

#Detach the  instances from the auto scaling group 
aws autoscaling detach-instances --instance-ids $instance_id --auto-scaling-group-name mywebserverdemo --should-decrement-desired-capacity
echo 'Running instances detached from the auto scaling group.'

#set the desired capacity  of the autoscaling group to zero which terminates the instances launched by the autoscaling group
aws autoscaling set-desired-capacity --auto-scaling-group-name mywebserverdemo --desired-capacity 0 

#De-rigister instances from the load balancer
aws elb deregister-instances-from-load-balancer --load-balancer-name itmo-544-wk4 --instances $instance_id
echo 'Instances De-registered from load balancer'

#deleting load balancer
aws elb delete-load-balancer --load-balancer-name itmo-544-wk4
echo 'Load Balancer deleted successfully.'

#terminate instances running.
aws ec2 terminate-instances --instance-ids $instance_id
echo 'Running instances were terminated.'

# wait for the instances to get terminated 
echo 'Waiting for instances to terminate...'
aws ec2 wait instance-terminated --instance-ids $instance_id

#deleting the auto scaling group
aws autoscaling delete-auto-scaling-group --auto-scaling-group-name mywebserverdemo --force-delete
echo 'Deleted auto scaling group successfully.'

#deleting launch configuration
aws autoscaling delete-launch-configuration --launch-configuration-name webserverdemo
echo 'Launch configuration deleted successfully.'