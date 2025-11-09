Got you. Here’s a clean, copy-paste walkthrough to deploy the provided Terraform setup on a **fresh Ubuntu (22.04/24.04)** box.

---

# 1) Update OS and install prerequisites

```bash
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl unzip gnupg lsb-release software-properties-common
```

# 2) Install Azure CLI

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az version
```

# 3) Install Terraform (HashiCorp repo)

```bash
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
| sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update -y
sudo apt-get install -y terraform
terraform -version
```

# 4) Grab the project files

If you downloaded the zip to your machine, copy it to the server (e.g., `scp`) and then:

```bash
cd ~
unzip azure-ha-dr-terraform.zip -d azure-ha-dr-terraform
cd azure-ha-dr-terraform
```

# 5) Create (or use) an SSH key for VM access

```bash
# Skip if you already have ~/.ssh/id_rsa.pub
ssh-keygen -t rsa -b 4096 -C "azureuser" -N "" -f ~/.ssh/id_rsa
PUBKEY=$(cat ~/.ssh/id_rsa.pub)
```

# 6) Log in to Azure and select a subscription

```bash
az login          # Opens a device login URL; follow the prompt
az account list -o table
az account set --subscription "<SUBSCRIPTION NAME OR ID>"
```

# 7) Create your `terraform.tfvars`

```bash
cat > terraform.tfvars <<'EOF'
prefix             = "myapp"
primary_location   = "East US"
secondary_location = "Central US"
ssh_public_key     = "<WILL_BE_REPLACED_BY_SCRIPT>"
# Optional tweaks:
# web_vmss_capacity = 2
# app_vmss_capacity = 2
# vm_sku            = "Standard_B2s"
# db_vm_size        = "Standard_B2ms"
EOF

# Inject your actual SSH public key into the file
sed -i "s#<WILL_BE_REPLACED_BY_SCRIPT>#$PUBKEY#g" terraform.tfvars
```

# 8) Initialize and preview

```bash
terraform init
terraform validate
terraform plan
```

# 9) Apply (deploy)

```bash
terraform apply -auto-approve
```

Deployment creates:

* Resource groups in **two regions**
* VNets/subnets (web/app/db)
* **Public LB** (web) + **Internal LB** (app, port 8080)
* VM Scale Sets for **WEB** (Nginx) and **APP** (Python HTTP on 8080)
* Two DB VMs in an availability set per region
* **Traffic Manager** (priority: primary → secondary)

# 10) Verify it’s working

Terraform prints outputs at the end. Test both region IPs and the global TM endpoint.

```bash
# Show outputs again if needed
terraform output

# Example checks (replace with your actual values):
TM=$(terraform output -raw traffic_manager_fqdn)
PRIMARY=$(terraform output -raw primary_public_ip)
SECONDARY=$(terraform output -raw secondary_public_ip)

# Web tier (Nginx on 80)
curl -I http://$PRIMARY
curl -I http://$SECONDARY
curl -I http://$TM
```

You should see HTTP 200/301 headers from Nginx. The Traffic Manager endpoint will point to the **primary** LB unless you simulate failure.

# 11) (Optional) SSH into a VM instance

Scale sets use NAT via the load balancer only for ports you expose; easiest path is to use **Azure Bastion** or add a temporary inbound rule/NAT. For quick testing you can open port 22 from your IP in the VMSS module’s NSG (already allowed to `*` in this starter), then find an instance’s private IP and SSH through a jump host, or add a temporary public IP to a single VM if needed.

# 12) Tear down when done

```bash
terraform destroy -auto-approve
```

---

## Common gotchas & fixes

* **Permissions**: Your Azure account needs permission to create RGs, VNets, LBs, VMSS, VMs, and Traffic Manager.
* **Unavailable regions**: If your subscription doesn’t support a chosen region/SKU, change `primary_location`, `secondary_location`, or `vm_sku` in `terraform.tfvars`.
* **Quota limits**: If VM/CPU quota is low, pick smaller SKUs (e.g., `Standard_B1s/B2s`) or request quota increases.
* **State management** (optional): For teams/CI, use a remote backend (e.g., Azure Storage). I can add an `azurerm` backend block if you want it wired up.

If you want me to: (a) wire in **Azure Site Recovery**, (b) swap the DB tier to **Azure Database** (managed), or (c) lock down NSGs with your office IPs only—say the word and I’ll extend the scripts.
