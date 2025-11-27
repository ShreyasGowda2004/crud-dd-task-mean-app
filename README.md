# MEAN Stack CRUD Application - DevOps Project

A full-stack CRUD application using the MEAN stack (MongoDB, Express, Angular 15, and Node.js), fully containerized with Podman/Docker and ready for cloud deployment.

## 🚀 Features

- Complete CRUD operations for tutorials
- Search functionality by title
- Fully containerized with Podman/Docker
- Nginx reverse proxy
- MongoDB database with persistent storage
- CI/CD pipeline with GitHub Actions
- Ready for production deployment

## 🌐 Live Deployment

**Application is live at:** http://4.240.92.132

### Deployed Infrastructure:
- **Platform:** Azure VM (Standard_B2s, 2 vCPUs, 4 GiB RAM)
- **OS:** Ubuntu 22.04 LTS
- **Region:** Central India
- **CI/CD:** GitHub Actions
- **Docker Images:** https://hub.docker.com/u/shreyasgowda2004

## 📦 Quick Start with Podman/Docker

### Prerequisites
- Podman or Docker installed
- Docker Hub account

### 1. Clone and Setup
```bash
git clone https://github.com/ShreyasGowda2004/crud-dd-task-mean-app.git
cd crud-dd-task-mean-app

# Create .env file
echo "DOCKER_USERNAME=shreyasgowda2004" > .env
```

### 2. Start Application
```bash
# Using Podman
podman-compose up -d

# OR using Docker
docker compose up -d
```

### 3. Access Application
- **Application**: http://localhost (or http://localhost:8888 for local testing)
- **API**: http://localhost/api/tutorials
- **Health Check**: http://localhost/health

## 🛠️ Local Development Setup

### Node.js Server
```bash
cd backend
npm install
node server.js
```
Backend runs on http://localhost:8080

### Angular Client
```bash
cd frontend
npm install
ng serve --port 8081
```
Frontend runs on http://localhost:8081

## 📚 Documentation

- **[QUICKSTART.md](./QUICKSTART.md)** - Fast deployment guide
- **[DEPLOYMENT.md](./DEPLOYMENT.md)** - Complete deployment instructions
- **[PROJECT_README.md](./PROJECT_README.md)** - Full project documentation
- **[ARCHITECTURE.md](./ARCHITECTURE.md)** - System architecture diagrams
- **[CHECKLIST.md](./CHECKLIST.md)** - Pre-deployment checklist

## 🐳 Docker Hub Images

- **Backend**: `shreyasgowda2004/mean-backend:latest`
- **Frontend**: `shreyasgowda2004/mean-frontend:latest`

## 🎯 Deployment

See [DEPLOYMENT.md](./DEPLOYMENT.md) for complete deployment instructions including:
- VM setup (AWS/Azure)
- CI/CD configuration
- GitHub Actions setup
- Production deployment

## 📝 Configuration

You can modify:
- MongoDB connection: `backend/app/config/db.config.js`
- API endpoints: `frontend/src/environments/environment*.ts`
- Nginx proxy: `nginx/nginx.conf`
