# README

## Add dev certs trust

Remember to run this in the terminal to trust the dev certs. If you are in Windows, even if you run this command from WSL, you will need to run it in the Windows terminal too.

```bash
dotnet dev-certs https --trust
```

## Requirements

You need:

* An **Azure KeyVault** with a wildcard certificate for the domain you will assign to the Application Gateway. The App Gateway then uses it to publish the Web PubSub endpoint and the Web App.
* A **User Assigned Managed Identity** with read access to the KeyVault where the SSL certificate is stored.
* A **Public DNS Zone in Azure**, where the script will create or update the A records for the Web PubSub service. Your user needs modify permissions to these DNS records, and they will be created with a resource reference.
* A **main.parameters.json** file in the root of the project with the following content:

  ```json
  {
    "parameters": {
      "keyVaultSecretId": {
        "value": "<Keyvault Secret Identifier (sid) for the SSL Certificate, you can omit the version number to get always the latest one>"
      },
      "keyVaultIdentityName": {
        "value": "<NAME OF THE Managed Identity that has cert read access rights in the KeyVault>"
      },
      "keyVaultIdentityRG": {
        "value": "<RESOURCE GROUP OF THE MANAGED IDENTITY>"
      },
      "customDnsZoneName": {
        "value": "<BASE DOMAIN NAME FOR THE PUBSUB SERVICE IN THE APPP GATEWAY, EX: mydomain.com>"      
      },
      "pubsubARecordName": {
        "value": "<SUBDOMAIN NAME USED FOR THE WEB PUBSUB SERVICE, EX: wss (for wss.mydomain.com)>"
      },
      "dnsZoneRG": {
        "value": "<NAME OF THE RG WHERE THE DNS SERVICE>"
      }
    }
  }
  ```

* Configure dotnet secrets or provide the values in the parameters file:

  ```bash
  dotnet user-secrets init
  dotnet user-secrets set "WEBPUBSUB_SERVICE_CONNECTION_STRING" "Endpoint=https://[servicename].webpubsub.azure.com;AccessKey=[accesskey];Version=1.0;
  ```

## How to deploy this project into Azure

You can run the `deploy` *make* recipe with the following optional parameters:

```bash
make deploy [RG_NAME=<RESOURCE GROUP NAME>] [LOCATION=<LOCATION>] [APP_NAME=<APP NAME>]
```

This makefile recipe deploys the infra into your Azure subscription, compiles the OcppServer source code and publishes it into the created App Service via a private Storage Account. It doesn't use the direct zip upload method because the Web App is protected with a Private Endpoint, and the *az cli* cannot upload the zip file directly to the service.

The App Service and Web Pub Sub endpoints are protected with Private Endpoints, and published through an Application Gateway.
