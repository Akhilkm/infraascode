Terraform commands
```
terraform init => initializes the present directory
terrafrom plan => dry run
terraform apply => Create the infra
```

AWS IAM Roles required
```
1) EC2Role (ecsInstanceRole)
    allows the ECS agent on the EC2 hosts to communicate with ECS and ECR
2) ECSRole (ecsRole)
    role which authorizes the ECS to manage resources on your behalf
3) ECSTaskExecutionRole (ecsTaskExecutionRole)
    role attached to the ECS tasks
4) AutoscalingRole (ecsAutoscalingRole)
    used to allow AWS autoscaling to inspect stats and adjust scalable targets
```