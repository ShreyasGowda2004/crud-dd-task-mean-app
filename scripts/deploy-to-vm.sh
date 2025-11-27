#!/bin/bash

# Deploy to VM script
# Usage: ./scripts/deploy-to-vm.sh <vm-host> <vm-user> <ssh-key-path> <docker-username>

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check arguments
if [ $# -lt 4 ]; then
    echo -e "${RED}Error: Missing arguments${NC}"
    echo "Usage: ./scripts/deploy-to-vm.sh <vm-host> <vm-user> <ssh-key-path> <docker-username>"
    echo ""
    echo "Example:"
    echo "  ./scripts/deploy-to-vm.sh 54.123.45.67 ubuntu ~/.ssh/my-key.pem johndoe"
    exit 1
fi

VM_HOST=$1
VM_USER=$2
SSH_KEY=$3
DOCKER_USERNAME=$4

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Deploying to VM${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "VM Host: $VM_HOST"
echo "VM User: $VM_USER"
echo "Docker Username: $DOCKER_USERNAME"
echo ""

# Test SSH connection
echo -e "${YELLOW}Testing SSH connection...${NC}"
if ! ssh -i "$SSH_KEY" -o ConnectTimeout=10 "$VM_USER@$VM_HOST" "echo 'SSH connection successful'"; then
    echo -e "${RED}Error: Cannot connect to VM${NC}"
    exit 1
fi
echo -e "${GREEN}✓ SSH connection successful${NC}"
echo ""

# Create remote directory
echo -e "${YELLOW}Creating remote directory...${NC}"
ssh -i "$SSH_KEY" "$VM_USER@$VM_HOST" "mkdir -p ~/mean-app"
echo -e "${GREEN}✓ Directory created${NC}"
echo ""

# Copy files to VM
echo -e "${YELLOW}Copying files to VM...${NC}"
scp -i "$SSH_KEY" docker-compose.yml "$VM_USER@$VM_HOST:~/mean-app/"
scp -i "$SSH_KEY" -r nginx "$VM_USER@$VM_HOST:~/mean-app/"
echo -e "${GREEN}✓ Files copied${NC}"
echo ""

# Create .env file on VM
echo -e "${YELLOW}Creating .env file on VM...${NC}"
ssh -i "$SSH_KEY" "$VM_USER@$VM_HOST" "echo 'DOCKER_USERNAME=$DOCKER_USERNAME' > ~/mean-app/.env"
echo -e "${GREEN}✓ .env file created${NC}"
echo ""

# Deploy application
echo -e "${YELLOW}Deploying application...${NC}"
ssh -i "$SSH_KEY" "$VM_USER@$VM_HOST" << EOF
    cd ~/mean-app
    
    # Pull latest images
    podman-compose pull || podman compose pull
    
    # Stop old containers
    podman-compose down || podman compose down
    
    # Start new containers
    podman-compose up -d || podman compose up -d
    
    # Clean up
    podman image prune -af
    
    # Show status
    echo ""
    echo "Container status:"
    podman-compose ps || podman compose ps
EOF

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Deployment completed successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Application URL: http://$VM_HOST"
echo "API URL: http://$VM_HOST/api/tutorials"
echo "Health Check: http://$VM_HOST/health"
