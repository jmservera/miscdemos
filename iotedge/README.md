# IoT Edge simulator on WSL

To install it:

1. Deploy all the infra with `azd up`
2. Create a new ubuntu WSL instance in your computer with:
    ```pwsh
    wsl --install ubuntu --name [yournodename]
    ```
3. Run this script inside the WSL instance:
    ```bash
    curl -LsSf https://raw.githubusercontent.com/jmservera/miscdemos/refs/heads/jmservera/iotedge/iotedge/ubuntu-24.04-install.sh | sudo bash -s -- [YOUR_IOT_EDGE_CONNECTION_STRING]
    ```

---

If you want to create a new instance, you can run this:

```bash
DEVICE_NAME="[new device name]" azd deploy
```

