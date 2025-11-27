#!/bin/bash

################################################################################
# Azure VM Setup Script for MEAN Stack Deployment
# Run this script on your Azure Ubuntu VM after first SSH connection
#
# Usage: 
#   1. SSH into VM: ssh -i ~/.ssh/azure_vm_key azureuser@YOUR_VM_IP
#   2. Download this script: wget https://raw.githubusercontent.com/ShreyasGowda2004/crud-dd-task-mean-app/main/scripts/azure-vm-setup.sh
#   3. Make executable: chmod +x azure-vm-setup.sh
#   4. Run: ./azure-vm-setup.sh
################################################################################

set -e  # Exit on any error

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║       MEAN Stack Azure VM Setup - Automated Installation      ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Check if running on Ubuntu
if [ ! -f /etc/os-release ]; then
    print_error "Cannot detect OS. This script is for Ubuntu only."
    exit 1
fi

. /etc/os-release
if [ "$ID" != "ubuntu" ]; then
    print_error "This script is designed for Ubuntu. Detected: $ID"
    exit 1
fi

print_status "Detected Ubuntu $VERSION"
echo ""

################################################################################
# Step 1: Update System
################################################################################
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 1: Updating system packages..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
sudo apt update
sudo apt upgrade -y
print_status "System updated successfully"
echo ""

################################################################################
# Step 2: Install Docker
################################################################################
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 2: Installing Docker..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if command -v docker &> /dev/null; then
    print_warning "Docker already installed: $(docker --version)"
else
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    rm get-docker.sh
    print_status "Docker installed successfully"
fi

# Add current user to docker group
sudo usermod -aG docker $USER
print_status "Added $USER to docker group"
echo ""

################################################################################
# Step 3: Install Docker Compose
################################################################################
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 3: Installing Docker Compose..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if docker compose version &> /dev/null; then
    print_warning "Docker Compose already installed: $(docker compose version)"
else
    sudo apt install docker-compose-plugin -y
    print_status "Docker Compose installed successfully"
fi
echo ""

################################################################################
# Step 4: Start and Enable Docker
################################################################################
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 4: Starting Docker service..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
sudo systemctl start docker
sudo systemctl enable docker
print_status "Docker service started and enabled"
echo ""

################################################################################
# Step 5: Configure Firewall (UFW)
################################################################################
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 5: Configuring firewall..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
sudo ufw --force enable
sudo ufw allow 22/tcp  # SSH
sudo ufw allow 80/tcp  # HTTP
sudo ufw allow 443/tcp # HTTPS
print_status "Firewall configured (ports 22, 80, 443 open)"
sudo ufw status
echo ""

################################################################################
# Step 6: Install Additional Utilities
################################################################################
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 6: Installing additional utilities..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
sudo apt install -y \
    git \
    curl \
    wget \
    vim \
    htop \
    net-tools \
    unzip
print_status "Additional utilities installed"
echo ""

################################################################################
# Step 7: Create Application Directory
################################################################################
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 7: Creating application directory..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
mkdir -p ~/mean-app
cd ~/mean-app
print_status "Application directory created: ~/mean-app"
echo ""

################################################################################
# Step 8: Create .env File
################################################################################
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 8: Creating .env file..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat > ~/mean-app/.env << 'EOF'
# Docker Hub Configuration
DOCKER_USERNAME=shreyasgowda2004

# MongoDB Configuration
MONGODB_URI=mongodb://mongodb:27017/dd_db

# Backend Configuration
NODE_ENV=production
PORT=8080

# Frontend Configuration
API_URL=http://localhost:8080/api
EOF
print_status ".env file created"
echo ""

################################################################################
# Step 9: Display System Information
################################################################################
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "System Information:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "OS: $(lsb_release -d | cut -f2)"
echo "Kernel: $(uname -r)"
echo "Docker: $(sudo docker --version)"
echo "Docker Compose: $(docker compose version)"
echo "CPU: $(nproc) cores"
echo "RAM: $(free -h | grep Mem | awk '{print $2}')"
echo "Disk: $(df -h / | tail -1 | awk '{print $2}')"
echo ""

################################################################################
# Final Instructions
################################################################################
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                    SETUP COMPLETE! ✓                          ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
print_status "VM environment is ready for deployment!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "IMPORTANT: You must logout and login again for Docker group to take effect!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next steps:"
echo ""
echo "1. Logout from VM:"
echo "   exit"
echo ""
echo "2. SSH back in:"
echo "   ssh -i ~/.ssh/azure_vm_key azureuser@\$(curl -s ifconfig.me)"
echo ""
echo "3. Verify Docker works without sudo:"
echo "   docker ps"
echo ""
echo "4. Deploy application (choose one):"
echo ""
echo "   Option A - Manual deployment:"
echo "   ────────────────────────────────"
echo "   cd ~/mean-app"
echo "   git clone https://github.com/ShreyasGowda2004/crud-dd-task-mean-app.git ."
echo "   docker compose pull"
echo "   docker compose up -d"
echo ""
echo "   Option B - Automatic via GitHub Actions:"
echo "   ─────────────────────────────────────────"
echo "   1. Configure GitHub Secrets (see DEPLOYMENT_KEYS.txt)"
echo "   2. Push to GitHub: git push origin main"
echo "   3. GitHub Actions will deploy automatically"
echo ""
echo "5. Check deployment:"
echo "   docker compose ps"
echo "   curl http://localhost/health"
echo "   curl http://localhost/api/tutorials"
echo ""
echo "6. Access application in browser:"
echo "   http://\$(curl -s ifconfig.me)"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_warning "Remember to logout and login again now!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
