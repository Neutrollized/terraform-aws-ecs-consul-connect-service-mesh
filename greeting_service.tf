data "template_file" "greeting" {
  template = "${file("task_def_templates/consul-conenct-greeting.json.tpl")}"

  vars {
    svc_name              = "greeting"
    env_name              = "${var.environment}"
    region_name           = "${var.region}"
    container_cpu         = "100"
    container_min_mem     = "128"
    container_max_mem     = "256"
    container_port        = "8080"
    container_img         = "consul"
    container_img_version = "1.3.0"
  }
}

resource "aws_ecs_task_definition" "greeting_td" {
  family                = "service"
  container_definitions = "${data.template_file.greeting.rendered}"
}

resource "aws_ecs_service" "greeting_svc" {
  name = "greeting"

  cluster                            = "${aws_ecs_cluster.ecs_cluster.id}"
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  desired_count                      = "${var.desired_count}"

  network_configuration {
    security_groups = ["${aws_security_group.container_sg.id}"]
    subnets         = ["${aws_subnet.public_subnet1.id}", "${aws_subnet.public_subnet2.id}"]
  }

  task_definition = "${aws_ecs_task_definition.greeting_td.arn}"
}
