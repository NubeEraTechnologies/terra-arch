	# Pull outputs from Stage-1 (parent folder state file)
data "terraform_remote_state" "stage1" {
  backend = "local"
  config = {
    path = "../terraform.tfstate"
  }
}

