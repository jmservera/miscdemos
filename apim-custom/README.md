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
    "pubsubHostName": {
      "value": "<URI FOR THE PUBSUB SERVICE IN THE APPP GATEWAY, EX: wss.mydomain.com, you need to create an entry for it in your DNS with the IP generated for the GW>"
    },
    "keyVaultIdentityName": {
      "value": "<NAME OF THE Managed Identity that has cert read access rights in the KeyVault>"
    },
    "keyVaultIdentityRG": {
      "value": "<RESOURCE GROUP OF THE MANAGED IDENTITY>"
    }
  }
}
```

Then you can run:

```bash
make deploy RG_NAME=<RESOURCE GROUP NAME> LOCATION=<LOCATION> APP_NAME=<APP NAME>
```

> Remember to update your DNS server with the IP generated for the Application Gateway.