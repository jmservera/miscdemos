# Understand the generated Bicep files

#### In this article:
- [Generated file list](#generated-file-list)
- [Configure the files with Github Copilot for Azure](#configure-the-files-with-github-copilot-for-azure)
- [Deploy generated Bicep files to Azure](#deploy-generated-bicep-files-to-azure)
- [Details about the generated files](#details-about-the-generated-files)

CodeToCloud generates Bicep code to create Azure resources according to your infrastructure requirements and manages the connection between created Azure services. The generator takes care of app settings, authentication settings (identity enabling and role assignments), and public network settings to make your service work once deployed.

## Generated file list
The following files are generated to meet your infrastructure requirements.
- `azure.yaml`. AZD deployment yaml file, see [detail](#azureyaml).
- `main.bicep`. Main entry file, see [detail](#mainbicep).
- `main.parameters.json`. Parameters for deployment, see [detail](#mainparametersjson).
- Bicep Templates of Azure resources(see [detail](#other-bicep-files)):
  - `appservice.bicep`
  - `appserviceplan.bicep`
  - `containerregistry.bicep`
  - `appservice.apps.bicep`

## Configure the files with Github Copilot for Azure
You could make changes to the recommended infrastructure by [Github Copilot for Azure](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azure-github-copilot). Try the following prompts in the chat window:
1. @azure Replace container app with app service in the infrastructure.
2. @azure Add an environment variable KEY=val to my project.
3. @azure Update the environment variable KEY to \"val\" in the recommendation.

## Deploy generated Bicep files to Azure

1. Fill in the input parameters in `main.parameters.json`.
2. [Install Azure Developer CLI](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd?tabs=winget-windows%2Cbrew-mac%2Cscript-linux&pivots=os-windows) if you haven't already.
3. Run `azd up` to provision the resources and deploy your code. Refer to [Azure Developer CLI Get Started](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/get-started?tabs=localinstall&pivots=programming-language-nodejs).

## Details about the generated files

### azure.yaml
The `azure.yaml` defines and describes the apps and types of Azure resources and helps deploy your application on Azure using Azure Developer CLI(azd). Refer to [Azure Developer CLI's azure.yaml schema](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/azd-schema) for details.

### main.bicep
The `main.bicep` utilizes the `*.bicep` files as modules and defines the provisioning of your resources. The resources are created or updated in the following order:
- Dependency resources such as App Service Plan, etc.
- Compute resources such as App Service, etc.
- Target resources such as databases, storage, etc. If the target is connected to a compute resource, network and authentication settings are configured. Outbound IPs of the compute resources are added to the target's firewall rules. If the connection is using system identity, the principal ID is used to do role assignment. If the connection is using secret authentication, connection strings or keys are constructed or acquired.
- The deployment of app settings. The connection information, such as resource endpoint from the outputs of the target resources, is set in app settings.

### main.parameters.json
The `main.parameters.json` file defines the parameters for deployment, including the name of azd environment, location and resource group name. It might also contain parameters that need user input.

### Other Bicep files
For each resource type, a Bicep file, with its dependency resource files if any, is generated. The following is the description per resource type:

- Azure App Service

	`appserviceplan.bicep` defines the hosting App Service Plan.
	`appservice.bicep` defines an Azure App Service template with system identity enabled.
	`appservice.settings.bicep` defines an app settings template that is passed to the App Service. App settings for service bindings are passed through from `main.bicep`.
	`appservice.apps.bicep` defines the deployment of containerized applications within the App Service.
- Azure Container Registry

	`containerregistry.bicep` defines an Azure Container Registry template.

