# Read Stage-1 local state from parent folder
data "terraform_remote_state" "stage1" {
  backend = "local"
  config = {
    path = "../terraform.tfstate"
  }
}
