#!/bin/bash


echo "

      :::::::::       ::::::::::       ::::    :::      :::    :::         :::   :::       :::::::::       :::::::::           :::
     :+:    :+:      :+:              :+:+:   :+:      :+:    :+:        :+:+: :+:+:      :+:    :+:      :+:    :+:        :+: :+:
    +:+    +:+      +:+              :+:+:+  +:+      +:+    +:+       +:+ +:+:+ +:+     +:+    +:+      +:+    +:+       +:+   +:+
   +#++:++#+       +#++:++#         +#+ +:+ +#+      +#+    +:+       +#+  +:+  +#+     +#++:++#+       +#++:++#:       +#++:++#++:
  +#+             +#+              +#+  +#+#+#      +#+    +#+       +#+       +#+     +#+    +#+      +#+    +#+      +#+     +#+
 #+#             #+#              #+#   #+#+#      #+#    #+#       #+#       #+#     #+#    #+#      #+#    #+#      #+#     #+#
###             ##########       ###    ####       ########        ###       ###     #########       ###    ###      ###     ###

"

# Download necessary files
wget https://github.com/penumbra-zone/penumbra/releases/download/v0.70.3/pd-x86_64-unknown-linux-gnu.tar.xz
wget https://github.com/penumbra-zone/penumbra/releases/download/v0.70.3/pcli-x86_64-unknown-linux-gnu.tar.xz
wget https://github.com/cometbft/cometbft/releases/download/v0.37.5/cometbft_0.37.5_linux_amd64.tar.gz

# Extract downloaded files
sudo tar -xvf cometbft_0.37.5_linux_amd64.tar.gz
sudo tar -xvf pcli-x86_64-unknown-linux-gnu.tar.xz
sudo tar -xvf pd-x86_64-unknown-linux-gnu.tar.xz

# Move binaries to /usr/bin
sudo mv cometbft /usr/bin
sudo mv pcli-x86_64-unknown-linux-gnu/pcli /usr/bin
sudo mv pd-x86_64-unknown-linux-gnu/pd /usr/bin

# Clean up unnecessary files
rm CHANGELOG.md cometbft_0.37.5_linux_amd64.tar.gz LICENSE pcli-x86_64-unknown-linux-gnu.tar.xz pd-x86_64-unknown-linux-gnu.tar.xz README.md SECURITY.md UPGRADING.md
rm -rf pcli-x86_64-unknown-linux-gnu pd-x86_64-unknown-linux-gnu

# Prompt user to input IP address and Moniker
echo "Enter your IP address:"
read ip_address

echo "Enter your Moniker:"
read moniker

# Make sure that the value of the variables is initialized correctly
echo "IP address: $ip_address"
echo "Moniker: $moniker"

# Download the testnet files
pd testnet join --external-address $ip_address:26656 --moniker $moniker

# Create and configure systemd service for pd
printf "[Unit]
Description=pd node
After=network-online.target

[Service]
User=root
ExecStart=`which pd` start --home /root/.penumbra/testnet_data/node0/pd
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/pd.service

# Create and configure systemd service for cometbft
printf "[Unit]
Description=cometbft node
After=network-online.target

[Service]
User=root
ExecStart=`which cometbft` start --home /root/.penumbra/testnet_data/node0/cometbft
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/cometbft.service

# Start pd and cometbft services and check cometbft logs
sudo systemctl daemon-reload
sudo systemctl enable pd
sudo systemctl enable cometbft
sudo systemctl start pd
sudo systemctl start cometbft
sudo journalctl -u cometbft -fo cat
