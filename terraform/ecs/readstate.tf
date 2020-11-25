# Fetch data from remote tf state

# data "terraform_remote_state" "aws-state" {
#     backend = "s3"
#     config = {
#         bucket = "bucket name"
#         key = "path-to-state-file"
#         acces_key = var.AWS_ACCESS_KEY
#         secret_key = var.AWS_SECRET_KEY
#         region = var.AWS_REGION
#     }
  
# }