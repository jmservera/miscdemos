# IoT Edge simulator on WSL

To install it:

1. Deploy all the infra with `azd up`
2. Create a new ubuntu WSL instance in your computer
3. Run this script inside the WSL instance:
    ```bash
    curl -LsSf https://raw.githubusercontent.com/jmservera/miscdemos/refs/heads/jmservera/iotedge/iotedge/ubuntu-24.04-install.sh | sudo bash -s -- [YOUR_IOT_EDGE_CONNECTION_STRING]
    ```
