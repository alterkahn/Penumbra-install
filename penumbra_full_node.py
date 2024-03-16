import subprocess

# Download necessary files
subprocess.run(["wget", "https://github.com/penumbra-zone/penumbra/releases/download/v0.69.1/pd-x86_64-unknown-linux-gnu.tar.xz"])
subprocess.run(["wget", "https://github.com/penumbra-zone/penumbra/releases/download/v0.69.1/pcli-x86_64-unknown-linux-gnu.tar.xz"])
subprocess.run(["wget", "https://github.com/cometbft/cometbft/releases/download/v0.37.2/cometbft_0.37.2_linux_amd64.tar.gz"])

# Extract downloaded files
subprocess.run(["sudo", "tar", "-xvf", "cometbft_0.37.2_linux_amd64.tar.gz"])
subprocess.run(["sudo", "tar", "-xvf", "pcli-x86_64-unknown-linux-gnu.tar.xz"])
subprocess.run(["sudo", "tar", "-xvf", "pd-x86_64-unknown-linux-gnu.tar.xz"])

# Move binaries to /usr/bin
subprocess.run(["sudo", "mv", "cometbft", "/usr/bin"])
subprocess.run(["sudo", "mv", "pcli-x86_64-unknown-linux-gnu/pcli", "/usr/bin"])
subprocess.run(["sudo", "mv", "pd-x86_64-unknown-linux-gnu/pd", "/usr/bin"])

# Clean up unnecessary files
subprocess.run(["rm", "CHANGELOG.md", "cometbft_0.37.2_linux_amd64.tar.gz", "LICENSE", "pcli-x86_64-unknown-linux-gnu.tar.xz", "pd-x86_64-unknown-linux-gnu.tar.xz", "README.md", "SECURITY.md", "UPGRADING.md"])
subprocess.run(["rm", "-rf", "pcli-x86_64-unknown-linux-gnu", "pd-x86_64-unknown-linux-gnu"])

# Prompt the user for IP address
ip_address = input("Enter the IP address: ")

# Prompt the user for moniker
moniker = input("Enter your moniker: ")

# Download the testnet files and join
subprocess.run(["pd", "testnet", "join", "--external-address", f"{ip_address}:26656", "--moniker", moniker])

# Create and configure systemd service for pd
pd_service_content = """
[Unit]
Description=pd node
After=network-online.target

[Service]
User=root
ExecStart=`which pd` start --home /root/.penumbra/testnet_data/node0/pd
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
"""

with open("/etc/systemd/system/pd.service", "w") as pd_service_file:
    pd_service_file.write(pd_service_content)

# Create and configure systemd service for cometbft
cometbft_service_content = """
[Unit]
Description=cometbft node
After=network-online.target

[Service]
User=root
ExecStart=`which cometbft` start --home /root/.penumbra/testnet_data/node0/cometbft
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
"""

with open("/etc/systemd/system/cometbft.service", "w") as cometbft_service_file:
    cometbft_service_file.write(cometbft_service_content)

# Start pd and cometbft services
subprocess.run(["sudo", "systemctl", "daemon-reload"])
subprocess.run(["sudo", "systemctl", "enable", "pd"])
subprocess.run(["sudo", "systemctl", "enable", "cometbft"])
subprocess.run(["sudo", "systemctl", "start", "pd"])
subprocess.run(["sudo", "systemctl", "start", "cometbft"])

# Check cometbft logs
subprocess.run(["sudo", "journalctl", "-u", "cometbft", "-fo", "cat"])
