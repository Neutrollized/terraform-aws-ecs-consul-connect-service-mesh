 {
  "family": "${svc_name}",
  "containerDefinitions": [
    {
      "_comment": "comments here",
      "cpu": ${container_cpu},
      "memory": ${container_max_mem},
      "memoryReservation": ${container_min_mem},
      "networkMode": awsvpc,
      "environment": [],
      "name": "${svc_name}-proxy",
      "image": "${container_img_name}:${container_img_version}"
      "entryPoint": [
        "/bin/sh", "-c"
      ],
      "portMappings": [
        {
          "containerPort": ${container_port}
        }
      ],
      "command": [
        "exec consul connect proxy -register -service ${svc_name} -register-id $(hostname) -http-addr $(curl http://169.254.169.254/latest/meta-data/local-ipv4):8500 -listen $(hostname -i):8080 -service-addr $(hostname -i):${container_port}"
      ],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs"
        "options": {
          "awslogs-group": "${env_name}-service-${svc_name}",
          "awslogs-region": "${region_name}",
          "awslogs-stream-prefix": "consul-connect"
        }
      }
    }
  ]
}
