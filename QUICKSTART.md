# 🚀 Quick Start Guide

This guide will help you get the MEAN stack application up and running quickly.

## 📋 Prerequisites Checklist

Before you begin, ensure you have:
- [ ] GitHub account
- [ ] Docker Hub account
- [ ] Ubuntu VM (AWS/Azure/Other cloud)
- [ ] Docker installed locally (optional, for testing)
- [ ] Git installed

---

## 🎯 Option 1: Quick Local Test with Podman/Docker

### Step 1: Clone the repository
```bash
git clone <your-repository-url>
cd crud-dd-task-mean-app
```

### Step 2: Create environment file
```bash
# Create .env file
echo "DOCKER_USERNAME=your-dockerhub-username" > .env
```

### Step 3: Start the application
```bash
# Using Podman
podman-compose up -d

# OR using Docker
docker compose up -d
```

### Step 4: Access the application
Open your browser: http://localhost (or http://localhost:8888 for local Mac testing)

**To stop:**
```bash
podman-compose down   # or: docker compose down
```

---

## 🌐 Option 2: Full Production Deployment

### Phase 1: GitHub Repository Setup (5 minutes)

1. **Create new GitHub repository**
   - Go to https://github.com/new
   - Repository name: `crud-dd-task-mean-app`
   - Choose Public or Private
   - Click "Create repository"

2. **Push code to GitHub**
```bash
cd crud-dd-task-mean-app
git init
git add .
git commit -m "Initial commit with Docker and CI/CD"
git branch -M main
git remote add origin <your-repository-url>
git push -u origin main
```

---

### Phase 2: Docker Hub Setup (3 minutes)

1. **Create Docker Hub account**
   - Go to https://hub.docker.com
   - Sign up for free account
   - Remember your username

### 2. Create access token (recommended)
   - Go to Account Settings → Security → Access Tokens
   - Click "New Access Token"
   - Name it "GitHub Actions" or "Podman CLI"
   - Copy the token (you'll use this as `DOCKER_PASSWORD`)
   
**Current Setup**: Images already pushed to `shreyasgowda2004/mean-backend` and `shreyasgowda2004/mean-frontend`

---

### Phase 3: VM Setup (15 minutes)

#### 3.1: Launch Ubuntu VM

**AWS EC2:**
```bash
# Launch Ubuntu 22.04 LTS instance
# Instance type: t2.medium or higher
# Security group: Allow ports 22, 80, 443
```

**Azure:**
```bash
# Create Ubuntu 22.04 LTS VM
# Size: Standard_B2s or higher
# Allow ports: 22, 80, 443
```

#### 3.2: Setup VM
```bash
# SSH into your VM
ssh -i <your-key.pem> ubuntu@<vm-public-ip>

# Download and run setup script
wget https://raw.githubusercontent.com/<your-username>/crud-dd-task-mean-app/main/scripts/setup-vm.sh
chmod +x setup-vm.sh
./setup-vm.sh
```

**Or manually install Docker:**
```bash
# Update system
sudo apt-get update

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER

# Install Docker Compose
sudo apt-get install -y docker-compose-plugin

# Verify installation
docker --version
docker compose version
```

#### 3.3: Create application directory
```bash
mkdir -p ~/mean-app
cd ~/mean-app
```

---

### Phase 4: SSH Key Setup for CI/CD (5 minutes)

#### 4.1: Generate SSH key pair
```bash
# On your local machine or VM
ssh-keygen -t rsa -b 4096 -C "github-actions" -f ~/.ssh/github_actions_key -N ""
```

#### 4.2: Add public key to VM
```bash
# View public key
cat ~/.ssh/github_actions_key.pub

# SSH into VM and add it
ssh -i <your-key.pem> ubuntu@<vm-public-ip>
echo "<paste-public-key-here>" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
exit
```

#### 4.3: Save private key for GitHub
```bash
# Display private key
cat ~/.ssh/github_actions_key

# Copy the entire output (including BEGIN and END lines)
```

---

### Phase 5: GitHub Secrets Configuration (5 minutes)

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret** for each:

| Secret Name | Value | Where to Get It |
|------------|-------|-----------------|
| `DOCKER_USERNAME` | Your Docker Hub username | Docker Hub account |
| `DOCKER_PASSWORD` | Docker Hub password/token | Docker Hub access token |
| `VM_HOST` | VM public IP address | Cloud provider console |
| `VM_USERNAME` | `ubuntu` | VM default user |
| `VM_SSH_KEY` | Private SSH key | Output of `cat ~/.ssh/github_actions_key` |

**Important:** Copy the **entire** private key including:
```
-----BEGIN OPENSSH PRIVATE KEY-----
...
-----END OPENSSH PRIVATE KEY-----
```

---

### Phase 6: First Deployment (10 minutes)

#### Option A: Automatic via CI/CD
```bash
# Just push to trigger deployment
git add .
git commit -m "Trigger deployment"
git push origin main

# Watch the deployment
# Go to GitHub → Actions tab
```

#### Option B: Manual deployment
```bash
# From your local machine
./scripts/deploy-to-vm.sh \
  <vm-public-ip> \
  ubuntu \
  ~/.ssh/your-key.pem \
  your-dockerhub-username
```

---

### Phase 7: Verify Deployment (2 minutes)

#### Check if services are running
```bash
# SSH into VM
ssh ubuntu@<vm-public-ip>

cd ~/mean-app
docker compose ps

# All 4 containers should be running:
# - mean-mongodb
# - mean-backend
# - mean-frontend
# - mean-nginx
```

#### Test the application
```bash
# Health check
curl http://<vm-public-ip>/health

# API test
curl http://<vm-public-ip>/api/tutorials

# Open in browser
http://<vm-public-ip>
```

---

## 🎉 Success Checklist

- [ ] Application loads in browser at `http://<vm-ip>`
- [ ] Can create a new tutorial
- [ ] Can view tutorials list
- [ ] Can edit tutorials
- [ ] Can delete tutorials
- [ ] Can search tutorials by title
- [ ] API responds at `http://<vm-ip>/api/tutorials`
- [ ] All 4 containers running (`docker compose ps`)

---

## 🛠️ Useful Commands

### On VM

```bash
# View logs
docker compose logs -f

# View specific service logs
docker compose logs -f backend
docker compose logs -f frontend

# Restart services
docker compose restart

# Stop services
docker compose down

# Start services
docker compose up -d

# View container status
docker compose ps

# Clean up
docker system prune -a
```

### Local Testing

```bash
# Build images locally
./scripts/build-and-push.sh your-dockerhub-username

# Test locally
docker compose up -d

# View logs
docker compose logs -f

# Stop
docker compose down
```

---

## 🚨 Common Issues & Solutions

### Issue: Cannot SSH into VM
```bash
# Check VM security group allows port 22
# Verify key permissions
chmod 600 ~/.ssh/your-key.pem

# Test connection
ssh -v ubuntu@<vm-ip>
```

### Issue: Containers not starting
```bash
# Check logs
docker compose logs

# Check disk space
df -h

# Restart Docker
sudo systemctl restart docker
docker compose up -d
```

### Issue: Port 80 already in use
```bash
# Find what's using port 80
sudo lsof -i :80

# Stop Apache if installed
sudo systemctl stop apache2
sudo systemctl disable apache2
```

### Issue: CI/CD failing
- Verify all GitHub secrets are set correctly
- Check if VM is accessible from internet
- Ensure private SSH key is complete (including BEGIN/END lines)
- Check GitHub Actions logs for specific errors

### Issue: MongoDB connection failed
```bash
# Check MongoDB container
docker compose logs mongodb

# Restart MongoDB
docker compose restart mongodb
```

---

## 📈 Next Steps

After successful deployment:

1. **Enable HTTPS** with Let's Encrypt (optional)
2. **Set up monitoring** with Grafana/Prometheus
3. **Configure backups** for MongoDB
4. **Add custom domain** with DNS
5. **Implement logging** aggregation
6. **Set up alerts** for downtime

---

## 📚 Documentation

- [Full Deployment Guide](./DEPLOYMENT.md)
- [Project README](./PROJECT_README.md)
- [API Documentation](#api-endpoints-in-project_readmemd)

---

## 🆘 Need Help?

1. Check logs: `docker compose logs -f`
2. Review [DEPLOYMENT.md](./DEPLOYMENT.md) troubleshooting section
3. Verify all environment variables
4. Check GitHub Actions workflow logs
5. Ensure VM firewall rules are correct

---

## ⏱️ Total Time Estimate

- **Quick Local Test**: 5 minutes
- **Full Production Setup**: ~45 minutes
  - GitHub: 5 min
  - Docker Hub: 3 min
  - VM Setup: 15 min
  - SSH Keys: 5 min
  - GitHub Secrets: 5 min
  - Deployment: 10 min
  - Verification: 2 min

---

**🎊 Congratulations! Your MEAN stack application is now live!**

Access your application at: `http://<your-vm-ip>`
