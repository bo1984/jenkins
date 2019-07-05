#!/bin/bash

#Using script from http://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_cloudwatch_logs.html
# Install awslogs and the jq JSON parser
yum install -y awslogs jq nfs-utils
yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
start amazon-ssm-agent

# ECS config
{
  echo "ECS_CLUSTER=${ecs_cluster}"
  echo 'ECS_AVAILABLE_LOGGING_DRIVERS=${ecs_logging}'
  echo "ECS_INSTANCE_ATTRIBUTES={\"service\":\"jenkins\"}"
} >> /etc/ecs/ecs.config

# Inject the CloudWatch Logs configuration file contents
mkdir /etc/awslogs/
touch /etc/awslogs/awslogs.conf

cat > /etc/awslogs/awslogs.conf <<- EOF
[general]
state_file = /var/lib/awslogs/agent-state        
 
[/var/log/dmesg]
file = /var/log/dmesg
log_group_name = ${cloudwatch_prefix}/var/log/dmesg
log_stream_name = ${ecs_cluster}/{container_instance_id}
[/var/log/messages]
file = /var/log/messages
log_group_name = ${cloudwatch_prefix}/var/log/messages
log_stream_name = ${ecs_cluster}/{container_instance_id}
datetime_format = %b %d %H:%M:%S
[/var/log/docker]
file = /var/log/docker
log_group_name = ${cloudwatch_prefix}/var/log/docker
log_stream_name = ${ecs_cluster}/{container_instance_id}
datetime_format = %Y-%m-%dT%H:%M:%S.%f
[/var/log/ecs/ecs-init.log]
file = /var/log/ecs/ecs-init.log.*
log_group_name = ${cloudwatch_prefix}/var/log/ecs/ecs-init.log
log_stream_name = ${ecs_cluster}/{container_instance_id}
datetime_format = %Y-%m-%dT%H:%M:%SZ
[/var/log/ecs/ecs-agent.log]
file = /var/log/ecs/ecs-agent.log.*
log_group_name = ${cloudwatch_prefix}/var/log/ecs/ecs-agent.log
log_stream_name = ${ecs_cluster}/{container_instance_id}
datetime_format = %Y-%m-%dT%H:%M:%SZ
[/var/log/ecs/audit.log]
file = /var/log/ecs/audit.log.*
log_group_name = ${cloudwatch_prefix}/var/log/ecs/audit.log
log_stream_name = ${ecs_cluster}/{container_instance_id}
datetime_format = %Y-%m-%dT%H:%M:%SZ
EOF

# Set the region to send CloudWatch Logs data to (the region where the container instance is located)
region=$(curl 169.254.169.254/latest/meta-data/placement/availability-zone | sed s'/.$//')
sed -i -e "s/region = us-east-1/region = $region/g" /etc/awslogs/awscli.conf

# Set the ip address of the node 
container_instance_id=$(curl 169.254.169.254/latest/meta-data/local-ipv4)
sed -i -e "s/{container_instance_id}/$container_instance_id/g" /etc/awslogs/awslogs.conf

touch /etc/init/awslogjob.conf
cat > /etc/init/awslogjob.conf <<- EOF
#upstart-job
description "Configure and start CloudWatch Logs agent on Amazon ECS container instance"
author "Amazon Web Services"
start on started ecs
script
	exec 2>>/var/log/ecs/cloudwatch-logs-start.log
	set -x
	
	until curl -s http://localhost:51678/v1/metadata
	do
		sleep 1	
	done
	
	service awslogs start
	chkconfig awslogs on
end script
EOF

start ecs

#Get ECS instance info, althoug not used in this user_data it self this allows you to use
#az(availability zone) and region
until $(curl --output /dev/null --silent --head --fail http://localhost:51678/v1/metadata); do
  printf '.'
  sleep 5
done
instance_arn=$(curl -s http://localhost:51678/v1/metadata | jq -r '. | .ContainerInstanceArn' | awk -F/ '{print $NF}' )
az=$(curl -s http://instance-data/latest/meta-data/placement/availability-zone)

#Custom userdata script code
mkdir /var/jenkins_home
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 ${efs_name}:/ /var/jenkins_home
useradd jenkins -u 1000
chown jenkins:jenkins /var/jenkins_home
chmod 777 /var/jenkins_home
cp /etc/fstab /etc/fstab.bak
echo ${efs_name}:/ /var/jenkins_home nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0 | sudo tee -a /etc/fstab
echo "Done"