# MEAN Stack Application - Deployment Guide

This guide provides comprehensive instructions for deploying the MEAN stack application using Docker, Docker Compose, and CI/CD with GitHub Actions.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Local Development Setup](#local-development-setup)
3. [Docker Hub Setup](#docker-hub-setup)
4. [Ubuntu VM Setup](#ubuntu-vm-setup)
5. [GitHub Repository Setup](#github-repository-setup)
6. [CI/CD Configuration](#cicd-configuration)
7. [Deployment](#deployment)
8. [Troubleshooting](#troubleshooting)

---

## Prerequisites

- GitHub account
- Docker Hub account
- Ubuntu VM on AWS, Azure, or any cloud provider
- Basic knowledge of Docker/Podman, Docker Compose, and GitHub Actions

**Note**: This project works with both Docker and Podman. Examples use Docker for VM deployment and Podman for local development.

---

## Local Development Setup

### 1. Clone the repository
```bash
git clone <your-repository-url>
cd crud-dd-task-mean-app
```

### 2. Test with Podman/Docker (Recommended)

```bash
# Create .env file
echo "DOCKER_USERNAME=your-dockerhub-username" > .env

# Using Podman
podman-compose up -d

# OR using Docker
docker compose up -d

# Access at http://localhost or http://localhost:8888
```

### 3. Test locally without containers (Optional)

**Backend:**
```bash
cd backend
npm install
node server.js
```

**Frontend:**
```bash
cd frontend
npm install
ng serve --port 8081
```

---

## Docker Hub Setup

### 1. Create a Docker Hub account
- Go to https://hub.docker.com and sign up
- Remember your username for later use

### 2. Create repositories (Optional)
You can create two repositories:
- `mean-backend`
- `mean-frontend`

Note: Repositories will be created automatically when you push images.

---

## Ubuntu VM Setup

### 1. Launch an Ubuntu VM
- **AWS**: Use EC2 with Ubuntu 22.04 LTS
- **Azure**: Use Virtual Machine with Ubuntu 22.04 LTS
- **Other cloud providers**: Use Ubuntu 22.04 LTS

### 2. Configure Security Groups/Firewall
Open the following ports:
- Port 22 (SSH)
- Port 80 (HTTP)
- Port 443 (HTTPS - optional)

### 3. SSH into your VM
```bash
ssh -i <your-key.pem> ubuntu@<vm-public-ip>
```

### 4. Install Docker
```bash
# Update package index
sudo apt-get update

# Install dependencies
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add user to docker group
sudo usermod -aG docker $USER

# Apply group changes
newgrp docker

# Verify installation
docker --version
docker compose version
```

### 5. Create application directory
```bash
mkdir -p ~/mean-app
cd ~/mean-app
```

### 6. Manual deployment (First time)

Create a `.env` file:
```bash
nano .env
```

Add the following:
```
DOCKER_USERNAME=your-dockerhub-username
```

Upload your `docker-compose.yml` and `nginx/` directory to the VM:
```bash
# From your local machine
scp -i <your-key.pem> docker-compose.yml ubuntu@<vm-public-ip>:~/mean-app/
scp -i <your-key.pem> -r nginx ubuntu@<vm-public-ip>:~/mean-app/
```

Start the application:
```bash
cd ~/mean-app
docker compose up -d
```

---

## GitHub Repository Setup

### 1. Create a new GitHub repository
- Go to https://github.com/new
- Name: `crud-dd-task-mean-app` (or your preferred name)
- Make it Public or Private

### 2. Push code to GitHub
```bash
cd crud-dd-task-mean-app

# Initialize git (if not already done)
git init

# Add remote
git remote add origin <your-repository-url>

# Add all files
git add .

# Commit
git commit -m "Initial commit with Docker and CI/CD setup"

# Push to main branch
git branch -M main
git push -u origin main
```

---

## CI/CD Configuration

### 1. Generate SSH Key for VM access
On your **local machine** or VM:
```bash
ssh-keygen -t rsa -b 4096 -C "github-actions" -f ~/.ssh/github_actions_key -N ""
```

### 2. Add public key to VM
```bash
# Copy the public key
cat ~/.ssh/github_actions_key.pub

# SSH into VM and add the key
ssh -i <your-key.pem> ubuntu@<vm-public-ip>
echo "<paste-public-key-here>" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

### 3. Configure GitHub Secrets
Go to your GitHub repository → Settings → Secrets and variables → Actions

Add the following secrets:

| Secret Name | Description | Example |
|------------|-------------|---------|
| `DOCKER_USERNAME` | Your Docker Hub username | `johndoe` |
| `DOCKER_PASSWORD` | Your Docker Hub password or access token | `your-password` |
| `VM_HOST` | Your VM's public IP address | `54.123.45.67` |
| `VM_USERNAME` | SSH username for VM | `ubuntu` |
| `VM_SSH_KEY` | Private SSH key content | Content of `~/.ssh/github_actions_key` |

To get the SSH private key:
```bash
cat ~/.ssh/github_actions_key
```
Copy the entire output including `-----BEGIN OPENSSH PRIVATE KEY-----` and `-----END OPENSSH PRIVATE KEY-----`

---

## Deployment

### Automatic Deployment (CI/CD)
Once configured, any push to the `main` or `master` branch will trigger:
1. Build Docker images for backend and frontend
2. Push images to Docker Hub
3. Deploy to your VM automatically

### Manual Deployment
If you need to deploy manually:

```bash
# SSH into VM
ssh ubuntu@<vm-public-ip>

cd ~/mean-app

# Pull latest images
docker compose pull

# Restart containers
docker compose down
docker compose up -d

# View logs
docker compose logs -f
```

---

## Accessing the Application

Once deployed, access the application at:
```
http://<vm-public-ip>
```

### API Endpoints
- Frontend: `http://<vm-public-ip>/`
- Backend API: `http://<vm-public-ip>/api/tutorials`
- Health Check: `http://<vm-public-ip>/health`

---

## Architecture

```
┌─────────────────────────────────────────────────┐
│              Nginx (Port 80)                     │
│            Reverse Proxy                         │
└─────────────┬───────────────────┬───────────────┘
              │                   │
              │                   │
    ┌─────────▼─────────┐  ┌─────▼──────────┐
    │   Frontend:80     │  │  Backend:8080   │
    │   (Angular)       │  │  (Node.js)      │
    └───────────────────┘  └────────┬────────┘
                                    │
                           ┌────────▼────────┐
                           │  MongoDB:27017  │
                           │   (Database)    │
                           └─────────────────┘
```

---

## Docker Commands Reference

### View running containers
```bash
docker compose ps
```

### View logs
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f backend
docker compose logs -f frontend
docker compose logs -f mongodb
docker compose logs -f nginx
```

### Restart services
```bash
# All services
docker compose restart

# Specific service
docker compose restart backend
```

### Stop services
```bash
docker compose down
```

### Remove all data (including volumes)
```bash
docker compose down -v
```

### Clean up Docker system
```bash
docker system prune -a
```

---

## Troubleshooting

### 1. Containers not starting
```bash
# Check logs
docker compose logs

# Check container status
docker compose ps -a

# Restart services
docker compose down
docker compose up -d
```

### 2. Cannot connect to MongoDB
```bash
# Check if MongoDB is running
docker compose ps mongodb

# Check MongoDB logs
docker compose logs mongodb

# Verify backend can reach MongoDB
docker compose exec backend ping mongodb
```

### 3. Frontend cannot reach backend
```bash
# Check Nginx configuration
docker compose exec nginx nginx -t

# Check backend logs
docker compose logs backend

# Verify network connectivity
docker network inspect mean-app_mean-network
```

### 4. Port already in use
```bash
# Check what's using port 80
sudo lsof -i :80

# Kill the process or change port in docker-compose.yml
```

### 5. CI/CD pipeline failing
- Verify all GitHub secrets are set correctly
- Check GitHub Actions logs
- Ensure VM is accessible via SSH
- Verify Docker Hub credentials

### 6. Out of disk space
```bash
# Clean up Docker
docker system prune -a --volumes

# Check disk usage
df -h
```

---

## MongoDB Options

### Option 1: MongoDB as Docker Container (Recommended)
Already configured in `docker-compose.yml`. Data persists in Docker volume.

### Option 2: MongoDB installed directly on VM
1. Install MongoDB:
```bash
# Import MongoDB GPG key
curl -fsSL https://www.mongodb.org/static/pgp/server-6.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb-server-6.0.gpg

# Add MongoDB repository
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list

# Install MongoDB
sudo apt-get update
sudo apt-get install -y mongodb-org

# Start MongoDB
sudo systemctl start mongod
sudo systemctl enable mongod
```

2. Update `docker-compose.yml` to remove MongoDB service and update backend environment:
```yaml
environment:
  - MONGODB_URI=mongodb://host.docker.internal:27017/dd_db
```

---

## Environment Variables

Create a `.env` file in the project root for local development:

```bash
DOCKER_USERNAME=your-dockerhub-username
MONGODB_URI=mongodb://mongodb:27017/dd_db
PORT=8080
```

---

## Security Best Practices

1. **Use Docker Hub Access Tokens** instead of passwords
2. **Restrict SSH access** to specific IP addresses
3. **Enable firewall** on VM (UFW)
4. **Regular updates**: Keep Docker and Ubuntu updated
5. **Use secrets management** for sensitive data
6. **Enable HTTPS** with Let's Encrypt (optional)

### Enable UFW Firewall
```bash
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

---

## Monitoring

### Check application health
```bash
# Health endpoint
curl http://<vm-ip>/health

# Backend API
curl http://<vm-ip>/api/tutorials

# Container stats
docker stats
```

### View resource usage
```bash
# CPU and Memory
htop

# Disk usage
df -h
```

---

## Backup and Recovery

### Backup MongoDB data
```bash
# Create backup directory
mkdir -p ~/backups

# Backup MongoDB
docker compose exec -T mongodb mongodump --out=/tmp/backup
docker cp mean-mongodb:/tmp/backup ~/backups/mongodb-$(date +%Y%m%d)
```

### Restore MongoDB data
```bash
# Copy backup to container
docker cp ~/backups/mongodb-20231125 mean-mongodb:/tmp/restore

# Restore
docker compose exec mongodb mongorestore /tmp/restore
```

---

## Updating the Application

### Backend or Frontend code changes
1. Push changes to GitHub
2. CI/CD pipeline will automatically:
   - Build new images
   - Push to Docker Hub
   - Deploy to VM

### Manual update
```bash
# Pull latest code
cd ~/mean-app
git pull origin main

# Rebuild and restart
docker compose up -d --build
```

---

## Performance Optimization

1. **Use Docker BuildKit** for faster builds
2. **Enable caching** in CI/CD pipeline
3. **Use multi-stage builds** (already implemented for frontend)
4. **Optimize images** with smaller base images (alpine)
5. **Use CDN** for static assets (optional)

---

## Support

For issues or questions:
1. Check the logs: `docker compose logs`
2. Review GitHub Actions workflow runs
3. Verify all environment variables and secrets
4. Check VM security groups and firewall rules

---

## License

This project is for educational/demonstration purposes.

---

## Contributors

Add your name and contribution details here.
