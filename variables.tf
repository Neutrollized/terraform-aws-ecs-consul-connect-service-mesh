varaible "client" {
  description = "Friendly env name that will be used for namespacing all cluster resources (e.g. northerngreen, tgod, aurorasky)"
}

variable "environment" {
  description = "Friendly env name that will be used for namespacing all cluster resources (e.g. test, staging, qa, production)"
  default     = "production"
}

// should stick strictly with EC2 unless you're sure app is stable (no mem leak or runaway processes)
variable "launch_type" {
  description = "Launch type to run service on (EC2 or FARGATE)"
  default     = "EC2"
}

variable "instance_type" {
  description = "EC2 instance type (t3 for burstable gp, m5 for general purpose, c5 for CPU intensive and r5 for memory intensive)"
  default     = "t3.medium"
}

variable "desired_count" {
  description = "Number of EC2 instances to launch in your ECS cluster"
  default     = "2"
}

variable "max_count" {
  description = "Max number of EC2 instances to scale to in your ECS cluster"
  default     = "3"
}

variable "sshkey_name" {
  description = "Name of SSH key that will be used to access the underlying hosts in teh cluster"
}
