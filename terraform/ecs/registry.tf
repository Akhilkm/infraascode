resource "aws_ecr_repository" "foo" {
    name = "akhil-${var.ENVIRONMENT}-registry"
    image_tag_mutability = "MUTABLE"

    image_scanning_configuration {
        scan_on_push = true
    }
    tags = {
        Name = "akhil-${var.ENVIRONMENT}-registry"
    }
}