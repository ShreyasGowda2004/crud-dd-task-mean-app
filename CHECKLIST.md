# ✅ Pre-Deployment Checklist

Use this checklist to ensure everything is ready before deploying to production.

---

## 📁 Project Files Verification

### Core Configuration Files
- [x] `docker-compose.yml` - Multi-service orchestration
- [x] `.env.example` - Environment variables template
- [x] `.gitignore` - Git ignore rules

### Backend Files
- [x] `backend/Dockerfile` - Backend container image
- [x] `backend/.dockerignore` - Build context optimization
- [x] `backend/app/config/db.config.js` - Environment variable support
- [x] `backend/server.js` - CORS enabled
- [x] `backend/package.json` - Dependencies defined

### Frontend Files
- [x] `frontend/Dockerfile` - Multi-stage build
- [x] `frontend/.dockerignore` - Build context optimization
- [x] `frontend/nginx.conf` - Internal Nginx config
- [x] `frontend/src/environments/environment.ts` - Dev config
- [x] `frontend/src/environments/environment.prod.ts` - Prod config
- [x] `frontend/src/app/services/tutorial.service.ts` - Environment-based API URL
- [x] `frontend/angular.json` - File replacement config
- [x] `frontend/package.json` - Dependencies defined

### Nginx Reverse Proxy
- [x] `nginx/nginx.conf` - Reverse proxy configuration

### CI/CD Pipeline
- [x] `.github/workflows/deploy.yml` - GitHub Actions workflow

### Documentation
- [x] `README.md` - Original project documentation
- [x] `PROJECT_README.md` - Complete project guide
- [x] `DEPLOYMENT.md` - Deployment instructions
- [x] `QUICKSTART.md` - Quick start guide
- [x] `ARCHITECTURE.md` - Architecture diagrams
- [x] `DELIVERABLES.md` - Project summary

### Helper Scripts
- [x] `scripts/build-and-push.sh` - Build and push images
- [x] `scripts/setup-vm.sh` - VM setup automation
- [x] `scripts/deploy-to-vm.sh` - Manual deployment
- [x] `scripts/dev-local.sh` - Local development
- [x] All scripts executable (chmod +x)

---

## 🔍 Pre-Push Verification

### Local Testing (Optional but Recommended)

#### Test 1: Backend Dockerfile Builds
```bash
cd backend
podman build -t test-backend .   # or: docker build -t test-backend .
```
- [x] Build completes without errors ✅
- [x] No security warnings ✅
- [x] Image size reasonable (<200MB) ✅

#### Test 2: Frontend Dockerfile Builds
```bash
cd frontend
podman build -t test-frontend .   # or: docker build -t test-frontend .
```
- [ ] Build completes without errors
- [ ] Angular build succeeds
- [ ] Image size reasonable (<50MB)

#### Test 3: Podman/Docker Compose Works
```bash
# Create .env
echo "DOCKER_USERNAME=shreyasgowda2004" > .env

# Start services
podman-compose up -d   # or: docker compose up -d

# Wait 30 seconds for startup
sleep 30

# Check all containers running
podman-compose ps   # or: docker compose ps
```
Expected: 4 containers running (mongodb, backend, frontend, nginx)

- [x] MongoDB container running ✅
- [x] Backend container running ✅
- [x] Frontend container running ✅
- [x] Nginx container running ✅

#### Test 4: Application Accessible
```bash
# Health check
curl http://localhost/health

# API check
curl http://localhost/api/tutorials

# Frontend (in browser)
open http://localhost
```
- [ ] Health endpoint returns "healthy"
- [ ] API returns JSON response
- [ ] Frontend loads in browser
- [ ] No console errors

#### Test 5: API Functionality
```bash
# Create tutorial
curl -X POST http://localhost/api/tutorials \
  -H "Content-Type: application/json" \
  -d '{"title":"Test","description":"Test tutorial","published":false}'

# Get all tutorials
curl http://localhost/api/tutorials
```
- [ ] Tutorial created successfully
- [ ] Tutorial appears in list
- [ ] Can view in browser UI

#### Cleanup
```bash
podman-compose down -v   # or: docker compose down -v
rm .env
```

---

## 📦 GitHub Repository Setup

### Before Creating Repository

- [ ] Choose repository name (e.g., `crud-dd-task-mean-app`)
- [ ] Decide on Public or Private
- [ ] Don't initialize with README (we have our own)

### Repository Creation Steps

1. [ ] Go to https://github.com/new
2. [ ] Enter repository name
3. [ ] Select visibility (Public/Private)
4. [ ] **Do NOT** check "Add a README"
5. [ ] **Do NOT** add .gitignore or license
6. [ ] Click "Create repository"
7. [ ] Copy the repository URL

### Push to GitHub

```bash
cd /Users/shreyasgowda/Downloads/crud-dd-task-mean-app

# Initialize git (if not already done)
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit: Complete MEAN stack with Docker and CI/CD setup"

# Add remote (replace with your URL)
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/YOUR-REPO.git

# Push
git push -u origin main
```

- [ ] Git initialized
- [ ] All files added and committed
- [ ] Remote added
- [ ] Pushed to main branch
- [ ] Verify files visible on GitHub

---

## 🐳 Docker Hub Setup

### Account Setup
- [ ] Docker Hub account created (https://hub.docker.com)
- [ ] Username noted down
- [ ] Email verified

### Access Token (Recommended over Password)
1. [ ] Login to Docker Hub
2. [ ] Go to Account Settings → Security
3. [ ] Click "New Access Token"
4. [ ] Name: "GitHub Actions CI/CD"
5. [ ] Permissions: Read, Write, Delete
6. [ ] Click "Generate"
7. [ ] **Copy token** (you won't see it again!)
8. [ ] Save token securely

---

## 🖥️ VM Setup

### VM Launch

#### AWS EC2
- [ ] AMI: Ubuntu Server 22.04 LTS
- [ ] Instance type: t2.medium or higher
- [ ] Storage: 20GB minimum
- [ ] Key pair: Downloaded and secured
- [ ] Security group configured:
  - [ ] Port 22 (SSH) - Your IP
  - [ ] Port 80 (HTTP) - 0.0.0.0/0
  - [ ] Port 443 (HTTPS) - 0.0.0.0/0
- [ ] Elastic IP assigned (optional but recommended)
- [ ] Public IP noted

#### Azure VM
- [ ] Image: Ubuntu Server 22.04 LTS
- [ ] Size: Standard_B2s or higher
- [ ] Disk: 30GB minimum
- [ ] SSH key created/uploaded
- [ ] Network security group configured:
  - [ ] Port 22 (SSH) - Your IP
  - [ ] Port 80 (HTTP) - Internet
  - [ ] Port 443 (HTTPS) - Internet
- [ ] Public IP noted

### VM Access Test
```bash
ssh -i <your-key.pem> ubuntu@<vm-public-ip>
```
- [ ] SSH connection successful
- [ ] Can execute commands
- [ ] Exit and reconnect works

### Docker Installation

#### Automated (Recommended)
```bash
# On VM
wget https://raw.githubusercontent.com/YOUR-USERNAME/YOUR-REPO/main/scripts/setup-vm.sh
chmod +x setup-vm.sh
./setup-vm.sh
```

#### Manual Installation
```bash
# Update system
sudo apt-get update && sudo apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER

# Install Docker Compose plugin
sudo apt-get install -y docker-compose-plugin

# Apply group changes (logout/login or use)
newgrp docker

# Verify
docker --version
docker compose version
```

- [ ] Docker installed
- [ ] Docker Compose installed
- [ ] User added to docker group
- [ ] Can run docker commands without sudo

### Application Directory
```bash
mkdir -p ~/mean-app
cd ~/mean-app
```
- [ ] Directory created

### Firewall Configuration (Optional)
```bash
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable
sudo ufw status
```
- [ ] UFW enabled (if desired)
- [ ] Ports opened

---

## 🔐 SSH Key Setup for CI/CD

### Generate Key Pair
```bash
ssh-keygen -t rsa -b 4096 -C "github-actions" -f ~/.ssh/github_actions_key -N ""
```
- [ ] Key pair generated
- [ ] Located at `~/.ssh/github_actions_key` (private)
- [ ] Located at `~/.ssh/github_actions_key.pub` (public)

### Add Public Key to VM
```bash
# View public key
cat ~/.ssh/github_actions_key.pub

# SSH into VM
ssh -i <your-key.pem> ubuntu@<vm-public-ip>

# Add public key
echo "PASTE-PUBLIC-KEY-HERE" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
exit
```

### Test New Key
```bash
ssh -i ~/.ssh/github_actions_key ubuntu@<vm-public-ip>
```
- [ ] Can connect with new key
- [ ] No password prompt

### Save Private Key for GitHub
```bash
cat ~/.ssh/github_actions_key
```
- [ ] Private key content copied
- [ ] Includes "-----BEGIN OPENSSH PRIVATE KEY-----"
- [ ] Includes "-----END OPENSSH PRIVATE KEY-----"
- [ ] Saved securely

---

## 🔑 GitHub Secrets Configuration

Go to: Repository → Settings → Secrets and variables → Actions

### Required Secrets

#### 1. DOCKER_USERNAME
- [ ] Click "New repository secret"
- [ ] Name: `DOCKER_USERNAME`
- [ ] Value: Your Docker Hub username
- [ ] Click "Add secret"

#### 2. DOCKER_PASSWORD
- [ ] Click "New repository secret"
- [ ] Name: `DOCKER_PASSWORD`
- [ ] Value: Docker Hub password or access token
- [ ] Click "Add secret"

#### 3. VM_HOST
- [ ] Click "New repository secret"
- [ ] Name: `VM_HOST`
- [ ] Value: VM public IP address (e.g., `54.123.45.67`)
- [ ] Click "Add secret"

#### 4. VM_USERNAME
- [ ] Click "New repository secret"
- [ ] Name: `VM_USERNAME`
- [ ] Value: `ubuntu` (or your VM username)
- [ ] Click "Add secret"

#### 5. VM_SSH_KEY
- [ ] Click "New repository secret"
- [ ] Name: `VM_SSH_KEY`
- [ ] Value: Content of `~/.ssh/github_actions_key` (entire private key)
- [ ] Ensure BEGIN and END lines included
- [ ] Click "Add secret"

### Verification
- [ ] All 5 secrets added
- [ ] Names match exactly (case-sensitive)
- [ ] No extra spaces in values
- [ ] Private key is complete

---

## 🚀 Deployment Readiness

### Pre-Deployment Checks

#### Files Ready
- [ ] All Docker files created
- [ ] All configuration files ready
- [ ] All documentation complete
- [ ] All scripts executable

#### Accounts Ready
- [ ] GitHub account configured
- [ ] Docker Hub account ready
- [ ] VM launched and accessible
- [ ] All credentials saved securely

#### Secrets Configured
- [ ] GitHub secrets added
- [ ] SSH key pair created
- [ ] Public key on VM
- [ ] Private key in GitHub

#### Network Ready
- [ ] VM has public IP
- [ ] Security groups configured
- [ ] Can SSH into VM
- [ ] VM can pull Docker images

### Initial Manual Deployment (Recommended)

Before enabling CI/CD, test manual deployment:

```bash
# Build images locally
./scripts/build-and-push.sh YOUR-DOCKERHUB-USERNAME

# Deploy to VM
./scripts/deploy-to-vm.sh \
  <vm-public-ip> \
  ubuntu \
  ~/.ssh/github_actions_key \
  YOUR-DOCKERHUB-USERNAME

# Or manually on VM
ssh ubuntu@<vm-public-ip>
cd ~/mean-app
# Upload docker-compose.yml and nginx/
docker compose up -d
```

- [ ] Images built successfully
- [ ] Images pushed to Docker Hub
- [ ] Deployment script completed
- [ ] All containers running on VM
- [ ] Application accessible

---

## 🧪 Post-Deployment Verification

### Container Health
```bash
# On VM
ssh ubuntu@<vm-public-ip>
cd ~/mean-app
docker compose ps
```
Expected output: 4 containers with status "Up"

- [ ] mean-mongodb: Up
- [ ] mean-backend: Up
- [ ] mean-frontend: Up
- [ ] mean-nginx: Up

### Service Health
```bash
# From local machine or VM
curl http://<vm-public-ip>/health
# Expected: "healthy"

curl http://<vm-public-ip>/api/tutorials
# Expected: JSON array (empty or with data)
```
- [ ] Health check returns "healthy"
- [ ] API returns valid JSON
- [ ] No 500 errors

### Application Functionality

Open in browser: `http://<vm-public-ip>`

- [ ] Page loads without errors
- [ ] No console errors in browser DevTools
- [ ] Navigation works
- [ ] Can create tutorial
- [ ] Can view tutorials list
- [ ] Can edit tutorial
- [ ] Can delete tutorial
- [ ] Can search by title
- [ ] Publish/unpublish works

### Check Logs
```bash
# On VM
docker compose logs -f
```
- [ ] No error messages
- [ ] Backend connected to MongoDB
- [ ] Requests logged properly

---

## 🔄 CI/CD Verification

### Trigger First CI/CD Deploy

```bash
# Make a small change
echo "# Deployment test" >> README.md
git add README.md
git commit -m "Test CI/CD deployment"
git push origin main
```

### Monitor GitHub Actions

1. [ ] Go to repository on GitHub
2. [ ] Click "Actions" tab
3. [ ] See workflow running
4. [ ] "Build and Push" job completes
5. [ ] "Deploy" job completes
6. [ ] No errors in logs

### Verify Auto-Deploy

- [ ] New images on Docker Hub
- [ ] Containers restarted on VM
- [ ] Application still accessible
- [ ] All features still working

---

## 📋 Final Checklist

### All Files Created
- [ ] 2 Dockerfiles (backend, frontend)
- [ ] 2 .dockerignore files
- [ ] 1 docker-compose.yml
- [ ] 2 Nginx configs (frontend, reverse proxy)
- [ ] 1 CI/CD workflow
- [ ] 2 environment files (frontend)
- [ ] 4 helper scripts
- [ ] 6 documentation files
- [ ] .env.example
- [ ] .gitignore

### All Accounts Setup
- [ ] GitHub account
- [ ] Docker Hub account
- [ ] Cloud provider account
- [ ] VM launched

### All Secrets Configured
- [ ] DOCKER_USERNAME
- [ ] DOCKER_PASSWORD
- [ ] VM_HOST
- [ ] VM_USERNAME
- [ ] VM_SSH_KEY

### All Tests Passed
- [ ] Local Docker build works
- [ ] Docker Compose works locally
- [ ] Application accessible on VM
- [ ] All features working
- [ ] CI/CD pipeline successful

### Documentation Complete
- [ ] README.md preserved
- [ ] PROJECT_README.md created
- [ ] DEPLOYMENT.md detailed
- [ ] QUICKSTART.md helpful
- [ ] ARCHITECTURE.md visual
- [ ] DELIVERABLES.md summary

---

## 🎉 Ready for Production!

If all items are checked:
✅ Your application is fully containerized
✅ Your application is deployed to the cloud
✅ Your CI/CD pipeline is working
✅ Your documentation is complete

### Next Steps

1. **Access your application**: `http://<vm-public-ip>`
2. **Monitor logs**: `docker compose logs -f`
3. **Make changes**: Push to GitHub, auto-deploy!
4. **Share**: Provide GitHub repo URL

---

## 📞 Support

If any checks fail, refer to:
- `QUICKSTART.md` - Fast troubleshooting
- `DEPLOYMENT.md` - Detailed instructions
- `ARCHITECTURE.md` - System understanding
- GitHub Actions logs - CI/CD errors
- Docker logs - Runtime issues

---

**Date Completed**: _______________

**VM IP Address**: _______________

**Docker Hub Username**: _______________

**GitHub Repository**: _______________

---

✅ **Checklist Complete - Ready to Deploy!**
