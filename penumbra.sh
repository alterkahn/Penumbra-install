#!/bin/bash

# Download Penumbra CLI
wget https://github.com/penumbra-zone/penumbra/releases/download/v0.64.1/pcli-x86_64-unknown-linux-gnu.tar.xz

# Extract and rename
tar -xvf pcli-x86_64-unknown-linux-gnu.tar.xz && mv pcli-x86_64-unknown-linux-gnu penumbra

# Clean up
rm pcli-x86_64-unknown-linux-gnu.tar.xz && cd penumbra

# Initialize and generate keys
./pcli init soft-kms generate

# View the address
./pcli view address
