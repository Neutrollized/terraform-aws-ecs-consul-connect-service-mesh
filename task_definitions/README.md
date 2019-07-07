# task definitions

Lear more about its [parameters](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html) in detail here.
A task defintiion doesn't actually run anything, you still need a [service](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_services.html) to instantiate the task definitions as a running task.

## via AWS Management Console

`Services` --> `ECS`
`Task Definitions` --> `Create new Task Definition`, select `EC2`
`Configure via JSON` (at the very bottom)
cut and paste your task definition here


## TL;DR

It needs to be written in JSON

### family (String)

In our case, this will be the client name as well (i.e. `internalaudit`)

### cpu (Integer)

The number of cpu units that will be reserved for the container (1 CPU = 1024 units).  This number is not the same as `requests` in kubernetes; this only guaranetees you a certain amount if everything is running hot.  

### memory (Integer)

The hard limit amount of memory (in MiB) to present to container.  If container exceeds `memory` value, it will be killed.

### memoryReservation (Integer)

The soft limit amount of memory (in MiB) to reserve for container.
