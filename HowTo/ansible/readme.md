# Ansible Automation Playbooks

Welcome! This repository is a curated collection of Ansible playbooks and supporting files that I use to automate various IT tasks. It includes real-world examples for managing Linux and Windows systems, VMware environments, Cisco devices, Active Directory, Google Cloud Platform, and more.

Whether you're just getting started with Ansible or looking to expand your automation toolkit, this repo aims to provide a solid foundation with practical examples and reusable patterns.

---

## 📁 Repository Structure

The directory is organized to keep things modular and scalable:

- `activedirectory_playbooks/` – Automations for Active Directory.
- `ansible_install_centos_7/` & `ansible_install_centos_8/` – Ansible installation guides for CentOS.
- `cisco_playbooks/` – Playbooks for Cisco device automation.
- `collections/` – Third-party or custom Ansible collections.
- `csv/` – CSV files for dynamic inventory or variable inputs.
- `files/` – Static files used in deployments.
- `gcp_playbooks/` – Automating tasks in Google Cloud Platform.
- `group_vars/` – Group-level variable definitions.
- `idrac_playbooks/` – Playbooks to manage Dell iDRAC interfaces.
- `instructions/` – How-to guides and documentation.
- `inventory/` – Ansible inventory files.
- `linux_playbooks/` – Linux administration and configuration.
- `roles/` – Reusable Ansible roles.
- `scripts/` – Helper scripts to support playbooks.
- `serviceaccount/` – Configuration related to service accounts.
- `templates/` – Jinja2 templates for dynamic config generation.
- `vault/` – Encrypted secrets using Ansible Vault.
- `vmware_playbooks/` – VMware automation examples.
- `windows_playbooks/` – Windows configuration playbooks.
- `ansible.cfg` – Configuration file to control Ansible behavior.
- `hosts` – Default static inventory file.
- `readme.md` – This file!

---

## 🚀 Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/edtechjeff/HowTo.git
   cd HowTo/HowTo/ansible
   ```

2. **Install Ansible:**

   Refer to:
   - `ansible_install_centos_7/`
   - `ansible_install_centos_8/`

   for installation instructions specific to CentOS versions.

3. **Set up your inventory:**
   Edit the `hosts` file with the IP addresses or hostnames of your target machines.

4. **Define variables:**
   Add host- or group-specific variables in `group_vars/` or `host_vars/` as needed.

5. **Run a playbook:**
   Example:
   ```bash
   ansible-playbook -i hosts linux_playbooks/example.yml
   ```

---

## 🔐 Using Ansible Vault

Secrets (like credentials or API keys) are stored securely using Ansible Vault.

To edit a vault-encrypted file:
```bash
ansible-vault edit vault/secrets.yml
```

To create a new one:
```bash
ansible-vault create vault/new_secret.yml
```

You can supply the vault password with `--ask-vault-pass` or `--vault-password-file`.

---

## 📄 License

This project is licensed under the [MIT License](../LICENSE).

---

If you find this helpful or have suggestions, feel free to open an issue or contribute! Happy automating 👨‍💻⚙️