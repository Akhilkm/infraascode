# Role for AWS ec2 instances
resource "aws_iam_role" "ecsInstanceRole" {
    name = "ecsInstanceRole"
    path = "/"
    assume_role_policy = data.aws_iam_policy_document.ecsInstancePolicy.json
}

data "aws_iam_policy_document" "ecsInstancePolicy" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type = "Service"
            identifiers = ["ec2.amazonaws.com"]
        }
    }
}

resource "aws_iam_role_policy_attachment" "ecsInstanceRoleAttachment" {
    role = aws_iam_role.ecsInstanceRole.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecsInstanceProfile" {
    name = "ecsInstanceProfile"
    path = "/"
    role = aws_iam_role.ecsInstanceRole.id
}

# Role for AWS ecs service
resource "aws_iam_role" "ecsRole" {
    name = "ecsRole"
    path = "/"
    assume_role_policy = data.aws_iam_policy_document.ecsServicePolicy.json
}

resource "aws_iam_role_policy_attachment" "ecsRoleAttachment" {
    role = aws_iam_role.ecsRole.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

data "aws_iam_policy_document" "ecsServicePolicy" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type = "Service"
            identifiers = ["ecs.amazonaws.com"]
        }
    }
}

# Role for AWS ecs autoscaling service
resource "aws_iam_role" "ecsAutoscalingRole" {
    name = "ecsAutoscalingRole"
    path = "/"
    assume_role_policy = data.aws_iam_policy_document.ecsAutoscalingPolicy.json
}

resource "aws_iam_role_policy_attachment" "ecsAutoscalingRoleAttachment" {
    role = aws_iam_role.ecsAutoscalingRole.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
}

data "aws_iam_policy_document" "ecsAutoscalingPolicy" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type = "Service"
            identifiers = ["autoscaling.amazonaws.com"]
        }
    }
}

# Role for AWS ecs tasks
resource "aws_iam_role" "ecsTaskExecutionRole" {
    name = "ecsTaskExecutionRole"
    path = "/"
    assume_role_policy = data.aws_iam_policy_document.ecsTasksPolicy.json
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRoleAttachment" {
    role = aws_iam_role.ecsTaskExecutionRole.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecsTasksPolicy" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type = "Service"
            identifiers = ["ecs-tasks.amazonaws.com"]
        }
    }
}