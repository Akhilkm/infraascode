resource "aws_ecs_task_definition" "akhil-nginx-task" {
    family                = "akhil-nginx-task"
    container_definitions = file("taskDefinitions/nginx.json")
}

resource "aws_ecs_service" "akhil-nginx-service" {
    name            = "akhil-nginx-service"
    cluster         = aws_ecs_cluster.akhil-ecs-cluster.id
    task_definition = aws_ecs_task_definition.akhil-nginx-task.arn
    desired_count   = 3
    iam_role        = aws_iam_role.ecsRole.arn

    ordered_placement_strategy {
        type  = "binpack"
        field = "cpu"
    }

    load_balancer {
        target_group_arn = aws_lb_target_group.akhil-ecs-target-group.arn
        container_name   = "nginx"
        container_port   = 80
    }
}