variable AWS_REGION {
    type = string
    default = "us-east-1"
}

variable ENVIRONMENT {
    type = string
}

variable VPC_CIDR {
    type = string
}

variable ENABLE_VPC_DNS_HOSTNAME {
  default     = true
}

variable ENABLE_VPC_DNS_SUPPORT {
  default     = true
}

variable AWS_ZONES {
    type = list(string)
    default = ["a", "b", "c"]
}

variable "AMIS" {
    type = map(string)
    default = {
        us-east-1 = "ami-0b260e8b9c98dd02f"
        us-east-2 = "ami-0174d713e1a480367"
        us-west-2 = "ami-0db98e57137013b2d"
    }
}

variable AWS_KEY_PAIR {
    type = string
    default = "akhil-test"
}

variable AWS_ASG_SIZE {
    type = object({
        instance_type = string
        max_instance_size = number
        min_instance_size = number
        desired_capacity = number
    })

    default = {
        instance_type = "t2.small"
        max_instance_size = 5
        min_instance_size = 1
        desired_capacity = 3
    }
}
