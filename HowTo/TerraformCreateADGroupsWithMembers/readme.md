# ***Testing not varified working*** ***May 2nd 2025***

## Structure and Files
/terraform-azure-ad-groups/
│
├── main.tf              # Main logic for group and user membership
├── variables.tf         # Input variables (e.g., group names, user emails)
├── terraform.tfvars     # Actual values for your variables
├── outputs.tf           # Optional: useful for debugging or reference
├── providers.tf         # Providers and authentication


## providers.tf
```
terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47.0"
    }
  }
}

# variables.tf
provider "azuread" {
  # uses your Azure CLI login
}
```
## variables.tf
```
variable "group_name" {
  type        = string
  description = "Name of the Azure AD group"
}

variable "user_emails" {
  type        = list(string)
  description = "List of user principal names to add to the group"
}
```

## terraform.tfvars
```
group_name  = "Terraform-Test-Group"
user_emails = [
  "user1@yourdomain.com",
  "user2@yourdomain.com"
]
```
## main.tf
```
resource "azuread_group" "example" {
  display_name     = var.group_name
  security_enabled = true
  mail_enabled     = false
}

# Lookup each user by UPN and store results in a list
data "azuread_user" "users" {
  for_each = toset(var.user_emails)
  user_principal_name = each.key
}

# Add each user to the group
resource "azuread_group_member" "group_members" {
  for_each = data.azuread_user.users

  group_object_id  = azuread_group.example.id
  member_object_id = each.value.id
}
```
outputs.tf (***Optional***)
```
output "group_id" {
  value = azuread_group.example.id
}
```

## Steps to Deploy
1. terraform init
2. terraform plan
3. terraform apply

# Bonus Method
## Structure
```
terraform-azure-groups/
├── main.tf
├── variables.tf
├── users.csv
├── generate-tfvars.ps1   <-- Your PowerShell script
├── terraform.auto.tfvars <-- Output from the script
├── outputs.tf            <-- (optional) if you define outputs
└── provider.tf           <-- (optional) if you separate provider config
```


1. If you want to make this more dynamic. you can use the following scripts. First you need a CSV with groupname, then username
    - exmample
```
group,email
Engineering-Team,user1@domain.com
Engineering-Team,user2@domain.com
Engineering-Team,user3@domain.com
```

2. Then you can run this powershell command to create an terraform.auto.tfvars file 
```
# Load CSV
$csvPath = "users.csv"
$csvData = Import-Csv -Path $csvPath

# Get unique group name
$groupName = ($csvData | Select-Object -First 1).group

# Get list of emails
$emails = $csvData | Select-Object -ExpandProperty email
$emailList = $emails | ForEach-Object { "`"$_`"" } -join ",`n  "

# Write to terraform.auto.tfvars
@"
group_name = "$groupName"

user_emails = [
  $emailList
]
"@ | Set-Content -Path "terraform.auto.tfvars"
```

3. The resulting file will look like this
```
group_name = "Engineering-Team"

user_emails = [
  "user1@domain.com",
  "user2@domain.com",
  "user3@domain.com"
]
```
