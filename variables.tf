# ECS Section
variable "ecs_cluster" {
  description = "Name for the ECS Cluster."
}
variable "ecs_logging" {
  default     = "[\"json-file\",\"splunk\",\"awslogs\"]"
  description = "Adding logging option to ECS that the Docker containers can use."
}
variable "cloudwatch_prefix" {
  description = "If you want to avoid cloudwatch collision or you don't want to merge all logs to one log group specify a prefix"
}
variable "jenkins_dc" {
  description = "Number of jenkins container instances to run"
}
variable "jenkins_task_count" {
  description = "Number of containers to run for Jenkins"
}
variable "deployment_max_percent" {
  description = "Max percentage of containers to run for deployment"
}
variable "deployment_min_percent" {
  description = "Miniumum percentage of containers to run for deployment"
}

# ASG Section
variable "jenkins_instance_type" {
    description = "Instance type used for Jenkins container instance"
}
variable "path_to_public_key" {
  description = "Path to public key"
}
variable "public_subnets" {
  description = "Public Subnets that Jenkins container instance(s) will use."
}