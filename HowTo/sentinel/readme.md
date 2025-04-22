# Microsoft Sentinel Deployment Resources

This directory contains resources and templates to facilitate the deployment and management of Microsoft Sentinel using Azure Lighthouse and Infrastructure as Code (IaC) practices.

## Overview

The provided materials aim to streamline the setup of Microsoft Sentinel across multiple tenants or subscriptions by leveraging Azure Lighthouse for delegated resource management.

## Directory Structure

- `arm/`: Contains Azure Resource Manager (ARM) templates for deploying Sentinel configurations.
- `playbooks/`: Houses Azure Logic Apps playbooks for automated incident response.
- `policies/`: Includes Azure Policy definitions to enforce organizational standards.
- `workbooks/`: Provides Azure Monitor workbooks for data visualization and analysis.
- `analytic/`: Features analytic rule templates for threat detection.
- `Hunting/`: Offers hunting query templates for proactive threat hunting.

## Getting Started

### Prerequisites

- An active Azure subscription.
- Appropriate permissions to deploy resources (e.g., Owner or Contributor role).
- Azure CLI or access to the Azure Portal.

### Deployment Steps

1. **Set Up Azure Lighthouse**

   Utilize the ARM templates in the `arm/` directory to establish Azure Lighthouse delegation. This enables cross-tenant management of Microsoft Sentinel.

2. **Deploy Sentinel Resources**

   Deploy the necessary Sentinel resources using the templates provided in the respective directories (`playbooks/`, `policies/`, `workbooks/`, `analytic/`, `Hunting/`).

3. **Configure Automation**

   Implement the Logic Apps playbooks from the `playbooks/` directory to automate incident response and other operational tasks.

## Additional Resources

- [Microsoft Sentinel Documentation](https://learn.microsoft.com/en-us/azure/sentinel/)
- [Azure Lighthouse Documentation](https://learn.microsoft.com/en-us/azure/lighthouse/)

## Contributing

Contributions are welcome! Please submit a pull request or open an issue to discuss changes.

## License

This project is licensed under the MIT License. See the [LICENSE](../LICENSE) file for details.
