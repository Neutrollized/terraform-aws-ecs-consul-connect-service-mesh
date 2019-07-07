locals {
  vpc_cidr     = "10.0.0.0/16"
  public1_cidr = "10.0.0.0/24"
  public2_cidr = "10.0.1.0/24"
}

// https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI_launch_latest.html
// aws ec2 describe-images --owners amazon --filters 'Name=name,Values=amzn2-ami-ecs-hvm-*' 'Name=virtualization-type,Values=hvm' 'Name=root-device-type,Values=ebs' 'Name=architecture,Values=x86_64' | jq -r '.Images | sort_by(.CreationDate)'
data "aws_ami" "latest_ecs" {
  most_recent = true
  owners      = ["591542846629"] # AWS

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

// https://www.terraform.io/docs/providers/aws/d/availability_zones.html
data "aws_availability_zones" "avail_az" {
  state = "available"
}

#----------------------
# Network & Firewalls
#----------------------
resource "aws_vpc" "vpc" {
  enable_dns_support   = "true"
  enable_dns_hsotnames = "true"
  cidr_block           = "${local.vpc_cidr}"

  tags = {
    Name = "${client}-${environment}-vpc"
  }
}

resource "aws_subnet" "public_subnet1" {
  availability_zone = "${data.aws_availability_zones.avail_az.names[0]}"
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${local.public1_cidr}"

  map_public_ip_on_launch = "true"

  tags = {
    Name = "${client}-${environment}-subnet1"
  }
}

resource "aws_subnet" "public_subnet2" {
  availability_zone = "${data.aws_availability_zones.avail_az.names[1]}"
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${local.public2_cidr}"

  map_public_ip_on_launch = "true"

  tags = {
    Name = "${client}-${environment}-subnet2"
  }
}

// this is the equiv of the following in CloudFormation:
//InternetGateway:
//  Type: AWS::EC2::InternetGateway
//GatewayAttachement:
//  Type: AWS::EC2::VPCGatewayAttachment
//  Properties:
//    VpcId: !Ref 'VPC'
//    InternetGatewayId: !Ref 'InternetGateway'
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_route_table" "public_rt" {
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_route" "public_r" {
  route_table_id         = "${aws_route_table.public_rt.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"
}

resource "aws_route_table_association" "public_subnet1_rta" {
  subnet_id      = "${aws_subnet.public_subnet1.id}"
  route_table_id = "${aws_route_table.public_rt.id}"
}

resource "aws_route_table_association" "public_subnet2_rta" {
  subnet_id      = "${aws_subnet.public_subnet2.id}"
  route_table_id = "${aws_route_table.public_rt.id}"
}

#-------------------------------
# ECS (cluster, sg, asg, etc.)
#-------------------------------
// https://www.terraform.io/docs/providers/aws/r/ecs_cluster.html
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "test-ecs-cluster"

  tags = {
    Name = "${client}-${environment}-ecs-cluster"
  }
}

resource "aws_security_group" "container_sg" {
  description = "Access to the ECS hosts that run containers"
  vpc_id      = "${aws_vpc.vpc.id}"
}

resource "aws_autoscaling_group" "ecs_asg" {
  name = "${aws_launch_configuration.container_instances.name}-asg"

  vpc_zone_identifier  = ["${aws_subnet.public_subnet1.id}", "${aws_subnet.public_subnet2.id}"]
  launch_configuration = "${aws_launch_configuration.container_instances.name}"
  min_size             = "1"
  max_size             = "${var.max_count}"
  desired_capacity     = "${var.desired_count}"

  lifecycle {
    create_before_destroy = "true"
  }
}

resource "aws_launch_configuration" "container_instances" {
  name = "${aws_ecs_cluster.ecs_cluster.name}-container-instance-lc"

  image_id             = "${data.aws_ami.latest_ecs.id}"
  security_groups      = ["${aws_security_group.container_sg.id}"]
  instance_type        = "${var.instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.ec2_instance_profile}"
  key_name             = "${var.sshkey_name}"

  user_data = <<EOF
#!/bin/bash -x

# Make a local dir for Consul to store its data in
mkdir -p /opt/consul/data

echo ECS_CLUSTER=${aws_ecs_cluster.ecs_cluster.name} >> /etc/ecs/ecs.config

# There's no CloudFormation helper scripts in Terraform
EOF
}
