# Azure Virtual Desktop Image Pipeline
A project to template packer build and deploy with terraform to azure virtual desktop. 

## Overview
This repository demonstrates how to set up a Packer build pipeline that feeds into an Azure Virtual Desktop (AVD) environment using Terraform. The process involves building a custom image with Packer, storing it in an Azure Shared Image Gallery, and then deploying an AVD environment that uses this custom image.

## Terraform

### Packer Build Infrastructure
This Terraform configuration deploys the necessary resources to build and store a Packer image in an Azure Shared Image Gallery.

### AVD Infrastructure
This Terraform configuration deploys an Azure Virtual Desktop environment and pulls the custom image built by Packer from the Shared Image Gallery. It also includes the necessary resources for FSLogix profile containers.

#### FSLogix Configuration
FSLogix is used to manage user profiles in the AVD environment. The following resources are created to support FSLogix:

- **Storage Account**: A storage account is created to store the FSLogix profile containers.
- **File Share**: A file share is created within the storage account to hold the profile containers.
- **Role Assignments**: Appropriate role assignments are made to allow users to access the storage account.

The `FSLogix.tf` file in the Terraform configuration handles the creation of these resources.

The `setup-host.ps1` script is used to configure FSLogix settings, such as enabling FSLogix profiles and setting the VHD location for profile containers. This is placed here because the storage account details need to be provided and those require the account to be deployed first.

## Packer
A Packer template with a build pipeline to create a custom image on commit and store it in an Azure image repository. The Packer build includes the installation and configuration of FSLogix.

#### FSLogix in Packer Build
The Packer build script includes steps to install and configure FSLogix on the custom image. 

## Setup

- Create an Azure Service Principal
- Give it access over the subscription
- Create GitHub Action Workflow Secrets

### Creating an App Registration
1. Go to the Azure portal and navigate to "Microsoft Entra ID".
2. Select "App registrations" and click "New registration".
3. Fill in the required fields and click "Register".
4. After registration, go to "Certificates & secrets" and create a new client secret.
5. Note down the "Application (client) ID", "Directory (tenant) ID", and the client secret value.

### Setting Role Assignment for App to Subscription
Depending on your needs, you can assign different roles to the Azure Service Principal:

#### Owner Access
For wide-ranging permissions, you can assign the "Owner" role to the Service Principal. This role grants full access to manage all resources, including the ability to assign roles in Azure RBAC.

#### Contributor Access and User Access Administrator Role
For more scoped permissions, you can assign the "Contributor" role along with the "User Access Administrator" role. This setup allows the Service Principal to manage resources without granting full access to assign roles.

Additionally, you can grant specific permissions such as "Desktop Virtualization User" and "Virtual Machine User Login" to limit access to only necessary actions.

### Required GitHub Secrets
- `AZURE_CLIENT_ID`: The client ID of the Azure Service Principal.
- `AZURE_SUBSCRIPTION_ID`: The subscription ID where the resources will be deployed.
- `AZURE_TENANT_ID`: The tenant ID of the Azure Active Directory.
- `ARM_CLIENT_SECRET`: The client secret of the Azure Service Principal.
- `AZURE_CREDENTIALS`: The JSON output from the Azure CLI command `az ad sp create-for-rbac --sdk-auth`.

## Build Workflow
The GitHub Actions workflow is set up to automate the process of building and deploying the infrastructure.

1. **Build Packer Infrastructure**: This job sets up the necessary infrastructure to build a Packer image.
2. **Packer Test**: This job runs Packer to build the custom image and store it in the Azure Shared Image Gallery.
3. **Build AVD Infrastructure**: This job deploys the Azure Virtual Desktop environment using the custom image from the Shared Image Gallery.

By following this process, you can automate the creation and deployment of custom images for your Azure Virtual Desktop environment.

![Packer Build Workflow](./diagrams/packer_build.drawio.svg)

## Destroy Workflow
To clean up your experiment and remove all the resources created by the workflows, you can use the destroy workflow. This workflow will ensure that all resources are properly deleted to avoid unnecessary costs.

### Running the Destroy Workflow
1. Navigate to the "Actions" tab in your GitHub repository.
2. Select the "Destroy Workflow" from the list of workflows.
3. Click on the "Run workflow" button and select the branch you want to run the workflow on.
4. Confirm the action to start the destroy process.

The destroy workflow will execute the necessary Terraform commands to destroy the infrastructure and clean up the resources.

By using the destroy workflow, you can ensure that your Azure environment remains clean and free of unused resources after your experiments.


