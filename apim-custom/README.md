# README

## Add dev certs trust

Remember to run this in the terminal to trust the dev certs. If you are in Windows, even if you run this command from WSL, you will need to run it in the Windows terminal too.

```bash
dotnet dev-certs https --trust
```

## Requirements

You need: 

* A KeyVault with a certificate (can be wildcard) for the domain you will assign to the Application Gateway that provides access to the Azure Pub Sub service.
* A User Assigned Managed Identity with read access to the KeyVault where the SSL certificate is stored.

Create a main.parameters.json file in the root of the project with the following content:

```json
{
  "parameters": {
    "keyVaultSecretId": {
      "value": "<KEYVAULT SECRET ID FOR SSL Certificate>"
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

Then you can run:

```bash
make deploy RG_NAME=<RESOURCE GROUP NAME> LOCATION=<LOCATION> APP_NAME=<APP NAME>
```

> Remember to update your DNS server with the IP generated for the Application Gateway.