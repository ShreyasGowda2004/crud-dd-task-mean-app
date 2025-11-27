# Azure VM Setup Guide for MEAN Stack Deployment

This guide walks you through setting up an Azure Virtual Machine and deploying your MEAN stack application.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Step 1: Generate SSH Keys](#step-1-generate-ssh-keys)
3. [Step 2: Create Azure VM](#step-2-create-azure-vm)
4. [Step 3: Configure VM Environment](#step-3-configure-vm-environment)
5. [Step 4: Configure GitHub Secrets](#step-4-configure-github-secrets)
6. [Step 5: Deploy Application](#step-5-deploy-application)
7. [Step 6: Verify Deployment](#step-6-verify-deployment)
8. [Troubleshooting](#troubleshooting)

---

## Prerequisites

- Azure account with active subscription
- Azure CLI installed (or use Azure Portal)
- Git installed locally
- Your GitHub repository: `https://github.com/ShreyasGowda2004/crud-dd-task-mean-app`

---

## Step 1: Generate SSH Keys

First, generate an SSH key pair for secure VM access and GitHub Actions deployment.

### On your local machine:

```bash
# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -C "azure-vm-deployment" -f ~/.ssh/azure_vm_key -N ""

# This creates:
# - ~/.ssh/azure_vm_key (private key - for GitHub Secrets)
# - ~/.ssh/azure_vm_key.pub (public key - for VM)
```

### View your keys:

```bash
# View public key (to add to Azure VM)
cat ~/.ssh/azure_vm_key.pub

# View private key (to add to GitHub Secrets)
cat ~/.ssh/azure_vm_key
```

**Important**: Copy both keys to a temporary text file - you'll need them soon.

---

## Step 2: Create Azure VM

### Option A: Using Azure Portal (Recommended for beginners)

#### 2.1 Login to Azure Portal
1. Go to [https://portal.azure.com](https://portal.azure.com)
2. Sign in with your Azure account

#### 2.2 Create Virtual Machine
1. Click **"Create a resource"** → **"Virtual Machine"**
2. Fill in the **Basics** tab:
   - **Subscription**: Select your subscription
   - **Resource group**: Create new → `mean-app-rg`
   - **Virtual machine name**: `mean-app-vm`
   - **Region**: Choose closest to you (e.g., `East US`, `West Europe`)
   - **Availability options**: No infrastructure redundancy required
   - **Security type**: Standard
   - **Image**: `Ubuntu Server 22.04 LTS - x64 Gen2`
   - **Size**: `Standard_B2s` (2 vCPUs, 4 GiB RAM) or `Standard_DS1_v2`
   - **Authentication type**: SSH public key
   - **Username**: `azureuser` (or your preference)
   - **SSH public key source**: Use existing public key
   - **SSH public key**: Paste content from `~/.ssh/azure_vm_key.pub`

#### 2.3 Configure Disks
1. Click **"Disks"** tab
   - **OS disk size**: 30 GiB (default)
   - **OS disk type**: Standard SSD (or Premium SSD for better performance)

#### 2.4 Configure Networking
1. Click **"Networking"** tab
   - **Virtual network**: Create new (default name is fine)
   - **Subnet**: default
   - **Public IP**: Create new
   - **NIC network security group**: Advanced
   - Click **"Create new"** for network security group

#### 2.5 Configure Network Security Group (NSG)
Add these inbound rules:

| Priority | Name | Port | Protocol | Source | Destination | Action |
|----------|------|------|----------|--------|-------------|--------|
| 100 | SSH | 22 | TCP | My IP address | Any | Allow |
| 110 | HTTP | 80 | TCP | Any | Any | Allow |
| 120 | HTTPS | 443 | TCP | Any | Any | Allow |

**Important**: Set SSH rule source to "My IP address" for security, then add GitHub Actions IP ranges later.

#### 2.6 Review and Create
1. Click **"Review + create"**
2. Wait for validation
3. Click **"Create"**
4. Wait 3-5 minutes for deployment

#### 2.7 Get VM Public IP
1. Go to your VM resource
2. Copy the **Public IP address** (e.g., `20.123.45.67`)
3. Save this - you'll need it for GitHub Secrets

---

### Option B: Using Azure CLI (Faster for experienced users)

```bash
# Login to Azure
az login

# Create resource group
az group create --name mean-app-rg --location eastus

# Create VM
az vm create \
  --resource-group mean-app-rg \
  --name mean-app-vm \
  --image Ubuntu2204 \
  --size Standard_B2s \
  --admin-username azureuser \
  --ssh-key-values ~/.ssh/azure_vm_key.pub \
  --public-ip-sku Standard \
  --verbose

# Open ports
az vm open-port --port 22 --resource-group mean-app-rg --name mean-app-vm --priority 100
az vm open-port --port 80 --resource-group mean-app-rg --name mean-app-vm --priority 110
az vm open-port --port 443 --resource-group mean-app-rg --name mean-app-vm --priority 120

# Get public IP
az vm show --resource-group mean-app-rg --name mean-app-vm --show-details --query publicIps -o tsv
```

---

## Step 3: Configure VM Environment

Now SSH into your VM and set up the required software.

### 3.1 Connect to VM

```bash
# Replace with your VM's public IP
ssh -i ~/.ssh/azure_vm_key azureuser@YOUR_VM_PUBLIC_IP

# Example:
# ssh -i ~/.ssh/azure_vm_key azureuser@20.123.45.67
```

### 3.2 Update System

```bash
sudo apt update && sudo apt upgrade -y
```

### 3.3 Install Docker

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Verify Docker installation
sudo docker --version
```

### 3.4 Install Docker Compose

```bash
# Install Docker Compose
sudo apt install docker-compose-plugin -y

# Verify installation
docker compose version
```

### 3.5 Configure Firewall (UFW)

```bash
# Enable UFW
sudo ufw --force enable

# Allow SSH, HTTP, HTTPS
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Check status
sudo ufw status
```

### 3.6 Create Deployment Directory

```bash
# Create app directory
mkdir -p ~/mean-app
cd ~/mean-app

# Verify you're in the right place
pwd
# Should output: /home/azureuser/mean-app
```

### 3.7 Test Docker (Important)

```bash
# Test Docker without sudo
docker run hello-world

# If this fails with permission error:
# 1. Logout: exit
# 2. SSH back in: ssh -i ~/.ssh/azure_vm_key azureuser@YOUR_VM_PUBLIC_IP
# 3. Try again: docker run hello-world
```

### 3.8 Create .env File

```bash
cd ~/mean-app

cat > .env << 'EOF'
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

# Verify file
cat .env
```

---

## Step 4: Configure GitHub Secrets

Now configure the GitHub repository secrets for automated deployment.

### 4.1 Collect Required Information

Before adding secrets, gather:

1. **DOCKER_USERNAME**: `shreyasgowda2004`
2. **DOCKER_PASSWORD**: Your Docker Hub password or access token
   - Get token at: https://hub.docker.com/settings/security
3. **VM_HOST**: Your Azure VM public IP (e.g., `20.123.45.67`)
4. **VM_USERNAME**: `azureuser` (or whatever you used)
5. **VM_SSH_KEY**: Content of `~/.ssh/azure_vm_key` (private key)

### 4.2 Get Private Key Content

On your **local machine** (not VM):

```bash
# Display private key (copy entire output including BEGIN/END lines)
cat ~/.ssh/azure_vm_key
```

Copy the **entire output**, including:
```
-----BEGIN OPENSSH PRIVATE KEY-----
...all the lines...
-----END OPENSSH PRIVATE KEY-----
```

### 4.3 Add Secrets to GitHub

1. Go to: https://github.com/ShreyasGowda2004/crud-dd-task-mean-app/settings/secrets/actions

2. Click **"New repository secret"** for each secret:

**Secret 1: DOCKER_USERNAME**
- Name: `DOCKER_USERNAME`
- Value: `shreyasgowda2004`
- Click "Add secret"

**Secret 2: DOCKER_PASSWORD**
- Name: `DOCKER_PASSWORD`
- Value: Your Docker Hub password or access token
- Click "Add secret"

**Secret 3: VM_HOST**
- Name: `VM_HOST`
- Value: Your VM public IP (e.g., `20.123.45.67`)
- Click "Add secret"

**Secret 4: VM_USERNAME**
- Name: `VM_USERNAME`
- Value: `azureuser`
- Click "Add secret"

**Secret 5: VM_SSH_KEY**
- Name: `VM_SSH_KEY`
- Value: Paste entire private key content (from `cat ~/.ssh/azure_vm_key`)
- Click "Add secret"

### 4.4 Verify Secrets

You should now see 5 secrets listed:
- ✅ DOCKER_USERNAME
- ✅ DOCKER_PASSWORD
- ✅ VM_HOST
- ✅ VM_USERNAME
- ✅ VM_SSH_KEY

---

## Step 5: Deploy Application

You have two deployment options:

### Option A: Automatic Deployment (Recommended)

The GitHub Actions workflow will automatically deploy when you push to main:

```bash
# On your local machine, make a small change to trigger deployment
cd /Users/shreyasgowda/Downloads/crud-dd-task-mean-app

# Update README or any file
echo "" >> README.md

# Commit and push
git add .
git commit -m "Trigger deployment to Azure VM"
git push origin main
```

**Monitor deployment**:
1. Go to: https://github.com/ShreyasGowda2004/crud-dd-task-mean-app/actions
2. Watch the workflow run
3. Should complete in 5-10 minutes

---

### Option B: Manual Deployment

If you prefer manual deployment or need to troubleshoot:

#### 5.1 SSH into VM

```bash
ssh -i ~/.ssh/azure_vm_key azureuser@YOUR_VM_PUBLIC_IP
cd ~/mean-app
```

#### 5.2 Clone Repository (first time only)

```bash
# Clone your repository
git clone https://github.com/ShreyasGowda2004/crud-dd-task-mean-app.git .

# Or if already cloned, pull latest
git pull origin main
```

#### 5.3 Login to Docker Hub

```bash
docker login
# Enter username: shreyasgowda2004
# Enter password: (your Docker Hub password)
```

#### 5.4 Deploy with Docker Compose

```bash
# Pull latest images
docker compose pull

# Start services
docker compose up -d

# Check status
docker compose ps

# View logs
docker compose logs -f
```

---

## Step 6: Verify Deployment

### 6.1 Check Container Status

On VM:
```bash
docker compose ps

# Should show all 4 services as "Up":
# - mongodb
# - backend
# - frontend
# - nginx
```

### 6.2 Check Health Endpoint

On VM:
```bash
curl http://localhost/health
# Should return: healthy
```

### 6.3 Test API

On VM:
```bash
curl http://localhost/api/tutorials
# Should return: [] or JSON array
```

### 6.4 Access from Browser

From your local machine:
```
http://YOUR_VM_PUBLIC_IP
```

Example: `http://20.123.45.67`

You should see the Angular frontend with the tutorials CRUD interface!

### 6.5 Test Full Functionality

1. **Create Tutorial**: Click "Add Tutorial" button, fill form, submit
2. **View Tutorials**: Should appear in list
3. **Edit Tutorial**: Click on tutorial, edit details
4. **Delete Tutorial**: Remove a tutorial
5. **Search**: Use search box to filter tutorials

---

## Troubleshooting

### Issue 1: Cannot Connect to VM

```bash
# Check VM is running
az vm get-instance-view --resource-group mean-app-rg --name mean-app-vm --query instanceView.statuses[1] --output table

# Restart VM if needed
az vm restart --resource-group mean-app-rg --name mean-app-vm
```

### Issue 2: Permission Denied (SSH)

```bash
# Check SSH key permissions
chmod 600 ~/.ssh/azure_vm_key

# Try connecting with verbose output
ssh -vvv -i ~/.ssh/azure_vm_key azureuser@YOUR_VM_PUBLIC_IP
```

### Issue 3: Docker Permission Denied on VM

```bash
# Add user to docker group again
sudo usermod -aG docker $USER

# Logout and login again
exit
ssh -i ~/.ssh/azure_vm_key azureuser@YOUR_VM_PUBLIC_IP

# Verify
docker ps
```

### Issue 4: Containers Not Starting

```bash
# Check logs
docker compose logs

# Check specific service
docker compose logs backend
docker compose logs mongodb

# Restart services
docker compose restart

# Full restart
docker compose down
docker compose up -d
```

### Issue 5: Port 80 Not Accessible

```bash
# Check nginx is running
docker compose ps nginx

# Check firewall
sudo ufw status

# Check Azure NSG rules in portal
# Ensure port 80 is open to 0.0.0.0/0
```

### Issue 6: GitHub Actions Deployment Fails

1. **Check Secrets**: Verify all 5 secrets are correctly set
2. **Check SSH Key**: Ensure private key has no extra spaces/newlines
3. **Check VM SSH Access**: Test manual SSH connection
4. **View Logs**: Check workflow logs in GitHub Actions tab
5. **Check VM Disk Space**: `df -h` (should have >2GB free)

### Issue 7: MongoDB Connection Issues

```bash
# Check MongoDB logs
docker compose logs mongodb

# Check backend can reach MongoDB
docker compose exec backend ping mongodb

# Restart MongoDB
docker compose restart mongodb backend
```

### Useful Commands

```bash
# View all logs
docker compose logs -f

# View specific service logs
docker compose logs -f backend

# Restart specific service
docker compose restart backend

# Stop all services
docker compose down

# Start services in foreground (see live logs)
docker compose up

# Remove all containers and volumes (CAUTION: deletes data)
docker compose down -v

# Check disk usage
df -h

# Check memory usage
free -h

# Check running processes
htop  # or top
```

---

## Cost Optimization

### Azure VM Costs

- **Standard_B2s**: ~$30-40/month (recommended)
- **Standard_B1s**: ~$15-20/month (minimum, may be slow)
- **Standard_DS1_v2**: ~$50-60/month (better performance)

### Save Money

1. **Stop VM when not in use**:
   ```bash
   az vm deallocate --resource-group mean-app-rg --name mean-app-vm
   ```

2. **Start VM when needed**:
   ```bash
   az vm start --resource-group mean-app-rg --name mean-app-vm
   ```

3. **Use Azure Reserved Instances** (1-year or 3-year commitment for 40-60% discount)

4. **Set up auto-shutdown** in Azure Portal → VM → Auto-shutdown

---

## Next Steps

After successful deployment:

1. ✅ **Set up custom domain** (optional)
2. ✅ **Configure SSL/HTTPS** with Let's Encrypt
3. ✅ **Set up monitoring** with Azure Monitor or Application Insights
4. ✅ **Configure backups** for MongoDB data
5. ✅ **Set up auto-scaling** if traffic increases

---

## Summary

You've successfully:
- ✅ Generated SSH keys for secure access
- ✅ Created Azure VM with Ubuntu 22.04 LTS
- ✅ Installed Docker and Docker Compose
- ✅ Configured GitHub Secrets for CI/CD
- ✅ Deployed MEAN stack application
- ✅ Verified application is accessible on port 80

**Your application is now live at**: `http://YOUR_VM_PUBLIC_IP`

For questions or issues, refer to the main documentation files:
- `DEPLOYMENT.md` - Comprehensive deployment guide
- `QUICKSTART.md` - Fast-track deployment steps
- `README.md` - Project overview and local development

---

**Congratulations! Your MEAN stack application is now running on Azure! 🎉**
