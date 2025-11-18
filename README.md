# Miscellaneus demos

An attempt to have a compendium of demos with some templates to deploy the needed resources in Azure.

* [Event Grid for IoT](./eventgrid/README.md): a demo of how to use Azure Event Grid MQTT capabilities to build an IoT environment, with some devices to test features like telemetry gathering, C2D messages, security, dashboard building, etc.
* [IoT Edge on WSL](./iotedge/README.md): a demo showing how to deploy Azure IoT Edge runtime on a WSL Ubuntu instance. Includes automated deployment with `azd` and a simple installation script for setting up IoT Edge on WSL.
* [OCPP Server](./ocpp-server/README.md): an example deployment of a website and a Web PubSub service to simulate an OCPP 1.6 service behind an Application Gateway. Demonstrates:
  * Application Gateway rewrite rules
  * Private Endpoints
  * WebApp Virtual Network integration
  * Web PubSub custom protocol
  * NAT Gateway
* [AI](./ai/): different demos demonstrating UX for AI with FluentAI, some Microsoft Copilot extension demos and a couple of Semantic Kernel simple demos for a console app and a web app.
* [Prompt Engineering Lab](https://jmservera.github.io/miscdemos/prompt-engineering): this repo contains the source of the Prompt Engineering Lab, a hands-on lab for learning the basic principles of Prompt Engineering.
