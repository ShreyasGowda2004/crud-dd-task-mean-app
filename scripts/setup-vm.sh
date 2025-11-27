#!/bin/bash

# Setup script for Ubuntu VM
# This script installs Docker, Docker Compose, and sets up the application directory
# Run this script on your Ubuntu VM

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Ubuntu VM Setup Script${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Update package index
echo -e "${YELLOW}Updating package index...${NC}"
sudo apt-get update

# Install dependencies
echo -e "${YELLOW}Installing dependencies...${NC}"
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
echo -e "${YELLOW}Adding Docker GPG key...${NC}"
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up Docker repository
echo -e "${YELLOW}Setting up Docker repository...${NC}"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
echo -e "${YELLOW}Installing Docker Engine...${NC}"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add current user to docker group
echo -e "${YELLOW}Adding user to docker group...${NC}"
sudo usermod -aG docker $USER

# Apply group changes
echo -e "${YELLOW}Applying group changes...${NC}"
newgrp docker <<EOF
echo -e "${GREEN}✓ Docker group applied${NC}"
EOF

# Verify Docker installation
echo -e "${YELLOW}Verifying Docker installation...${NC}"
docker --version
docker compose version
echo -e "${GREEN}✓ Docker installed successfully${NC}"
echo ""

# Create application directory
echo -e "${YELLOW}Creating application directory...${NC}"
mkdir -p ~/mean-app
cd ~/mean-app
echo -e "${GREEN}✓ Application directory created at ~/mean-app${NC}"
echo ""

# Configure firewall (optional but recommended)
echo -e "${YELLOW}Do you want to configure UFW firewall? (y/n)${NC}"
read -r configure_firewall

if [ "$configure_firewall" = "y" ]; then
    echo -e "${YELLOW}Configuring firewall...${NC}"
    sudo ufw allow 22/tcp
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    sudo ufw --force enable
    echo -e "${GREEN}✓ Firewall configured${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Setup completed successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Upload docker-compose.yml and nginx/ directory to ~/mean-app"
echo "2. Create .env file with DOCKER_USERNAME"
echo "3. Run: cd ~/mean-app && docker compose up -d"
echo ""
echo -e "${RED}Note: You may need to log out and back in for docker group changes to take effect${NC}"
