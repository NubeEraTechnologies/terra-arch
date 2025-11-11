data "terraform_remote_state" "stage1" {
  backend = "local"
  config = {
    path = "/home/azureuser/terra-arch-v1/stage1/terraform.tfstate"
  }
}

data "terraform_remote_state" "stage2" {
  backend = "local"
  config = {
    path = "/home/azureuser/terra-arch-v1/stage2/terraform.tfstate"
  }
}

data "terraform_remote_state" "stage3" {
  backend = "local"
  config = {
    path = "/home/azureuser/terra-arch-v1/stage3/terraform.tfstate"
  }
}
