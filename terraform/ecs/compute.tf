# ECS cluster
resource "aws_ecs_cluster" "akhil-ecs-cluster" {
    name = "akhil-${var.ENVIRONMENT}-ecs-cluster"
    tags = {
        Name = "akhil-${var.ENVIRONMENT}-ecs-cluster"
    }
}

# Security Group for ECS
resource "aws_security_group" "akhil-ecs-sg" {
    name        = "akhil-ecs-sg"
    description = "ECS inbound traffic"
    vpc_id      = aws_vpc.akhil-vpc.id

    ingress {
        description = "Web"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        security_groups = [aws_security_group.akhil-alb-public-sg.id]
    }
    ingress {
        description = "Traffic from VPC"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = [aws_vpc.akhil-vpc.cidr_block]
    }

    egress {
        description = "Allow all outbound traffic"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "akhil-ecs-sg"
    }
}

# Launch configuration for ECS cluster
resource "aws_launch_configuration" "ecsLaunchConfiguration" {
    name = "akhil-${var.ENVIRONMENT}-ecsLaunchConfiguration"
    image_id = lookup(var.AMIS, var.AWS_REGION)
    instance_type = var.AWS_ASG_SIZE.instance_type
    iam_instance_profile = aws_iam_instance_profile.ecsInstanceProfile.id

    root_block_device {
        volume_type = "standard"
        volume_size = 100
        delete_on_termination = true
    }

    lifecycle {
        create_before_destroy = true
    }

    security_groups = [aws_security_group.akhil-ecs-sg.id]
    associate_public_ip_address = "false"
    key_name = var.AWS_KEY_PAIR
    user_data = <<EOF
                #!/bin/bash
                echo ECS_CLUSTER=${aws_ecs_cluster.akhil-ecs-cluster.name} >> /etc/ecs/ecs.config
                EOF
}

# Auto Scaling group for ECS cluster
resource "aws_autoscaling_group" "ecs-autoscaling-group" {
    name = "akhil-${var.ENVIRONMENT}-ecs-autoscaling-group"
    max_size  = var.AWS_ASG_SIZE.max_instance_size
    min_size = var.AWS_ASG_SIZE.min_instance_size
    desired_capacity = var.AWS_ASG_SIZE.desired_capacity
    vpc_zone_identifier = aws_subnet.akhil-private-subnets.*.id
    launch_configuration = aws_launch_configuration.ecsLaunchConfiguration.name
    health_check_type = "ELB"
    tags = [{
        key = "Name"
        value = "akhil-ecs-instance"
        propagate_at_launch = true
    }]
}

# Security Group for ALB
resource "aws_security_group" "akhil-alb-public-sg" {
    name        = "akhil-alb-public-sg"
    description = "ALB security group"
    vpc_id      = aws_vpc.akhil-vpc.id

    ingress {
        description = "Web"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "Traffic from VPC"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = [aws_vpc.akhil-vpc.cidr_block]
    }

    egress {
        description = "Allow all outbound traffic"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "akhil-alb-public-sg"
    }
}

# ALB for ECS
resource "aws_lb" "akhil-ecs-alb" {
    name                = "akhil-ecs-alb"
    security_groups     = [aws_security_group.akhil-alb-public-sg.id]
    subnets             = aws_subnet.akhil-public-subnets.*.id

    tags = {
        Name = "akhil-ecs-alb"
    }
}

resource "aws_lb_target_group" "akhil-ecs-target-group" {
    name                = "akhil-ecs-target-group"
    port                = "80"
    protocol            = "HTTP"
    vpc_id              = aws_vpc.akhil-vpc.id

    health_check {
        healthy_threshold   = "5"
        unhealthy_threshold = "2"
        interval            = "30"
        matcher             = "200"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = "5"
    }

    tags = {
        Name = "akhil-ecs-target-group"
    }
}

resource "aws_lb_listener" "alb-listener" {
    load_balancer_arn = aws_lb.akhil-ecs-alb.arn
    port              = "80"
    protocol          = "HTTP"

    default_action {
        target_group_arn = aws_lb_target_group.akhil-ecs-target-group.arn
        type             = "forward"
    }
}