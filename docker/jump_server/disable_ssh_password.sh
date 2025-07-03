#!/bin/bash

# Define the path to the SSH daemon configuration file
SSHD_CONFIG_FILE="/etc/ssh/sshd_config"

echo "Disabling SSH password authentication..."

# Use sed to modify the PasswordAuthentication directive
# This command handles cases where the line is commented out or already set to 'yes'
sed -i -E 's|^#?(PasswordAuthentication)\s.*|\1 no|' "$SSHD_CONFIG_FILE"

# Ensure the line exists if it was not present (unlikely in default configs)
if ! grep -q '^PasswordAuthentication\sno' "$SSHD_CONFIG_FILE"; then
  echo "PasswordAuthentication no" | tee -a "$SSHD_CONFIG_FILE" > /dev/null
fi

# Optional: Disable ChallengeResponseAuthentication and UsePAM for stronger security
sed -i -E 's|^#?(ChallengeResponseAuthentication)\s.*|\1 no|' "$SSHD_CONFIG_FILE"
sed -i -E 's|^#?(UsePAM)\s.*|\1 no|' "$SSHD_CONFIG_FILE"

# echo "Restarting SSH service..."
# systemctl restart ssh
echo "SSH password authentication disabled. Please ensure key-based authentication is working before exiting."