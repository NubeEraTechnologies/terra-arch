# Read Stage-1 local state from parent folder
data "terraform_remote_state" "stage1" {
  backend = "local"
  config = {
    path = "/home/azureuser/terra-arch-v1/stage1/terraform.tfstate"
  }
}
