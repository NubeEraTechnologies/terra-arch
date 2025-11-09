# Azure HA/DR Reference Architecture – Terraform

This repository contains step-by-step modular Terraform stages to build a complete Highly Available + Disaster Recovery architecture in Azure.

---

## Folder Structure

```
/terraform
  /stage-1  -> creates RGs + VNets + Subnets
  /stage-2  -> creates Primary Web Tier (LB + 2 VMs in Zones)
  /stage-3  -> App Tier   (next)
  /stage-4  -> DB Tier    (next)
  /stage-5  -> Traffic Manager + DR site (next)
```

Each stage is separate → independent apply.
All stages can run individually.

---

## Requirements

| Tech      | version |
| --------- | ------- |
| Terraform | v1.6+   |
| Azure CLI | latest  |

Login:

```bash
az login
```

Make sure correct subscription is default:

```bash
az account show
```

---

## Stage-1

Creates **Primary** & **DR** Resource Groups + VNets + Subnets.

```bash
cd stage-1
terraform init
terraform apply -auto-approve
```

**after apply** get WEB subnet id:

```bash
terraform state show azurerm_subnet.primary_web
```

copy the `id` field

---

## Stage-2

Creates **Primary Web Tier** using Zones:

* Standard LB (Public)
* 2 Ubuntu VMs (zone1 + zone2)
* SSH key auto-generated

Create `terraform.tfvars` inside stage-2 folder:

```tf
primary_rg_name        = "<value from stage-1 output primary_rg>"
primary_subnet_web_id  = "<paste the primary_web subnet id>"
```

then run:

```bash
cd stage-2
terraform init
terraform apply -auto-approve
```

---

## Next

Ask ChatGPT to generate **stage-3** when ready:

* App tier (2 VMs zones or 1 VM)
