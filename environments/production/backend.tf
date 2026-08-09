terraform {
  backend "s3" {
    bucket       = "terraform-with-cicd-state"
    key          = "production/terraform.tfstate"
    region       = "ap-southeast-1"
    use_lockfile = true
    encrypt      = true
  }
}