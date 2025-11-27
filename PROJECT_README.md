# MEAN Stack CRUD Application - DevOps Task

A full-stack CRUD application built with MongoDB, Express.js, Angular 15, and Node.js. This project demonstrates containerization, deployment, and CI/CD practices.

## 🌐 **LIVE DEPLOYMENT**

**✅ Application is live and accessible at:**
👉 **http://4.240.92.132**

- **VM**: Azure Standard_B2s (Central India)
- **Docker Hub**: [shreyasgowda2004/mean-backend](https://hub.docker.com/r/shreyasgowda2004/mean-backend) & [shreyasgowda2004/mean-frontend](https://hub.docker.com/r/shreyasgowda2004/mean-frontend)
- **GitHub**: [ShreyasGowda2004/crud-dd-task-mean-app](https://github.com/ShreyasGowda2004/crud-dd-task-mean-app)

---

## 📋 Table of Contents
- [Features](#features)
- [Architecture](#architecture)
- [Technologies Used](#technologies-used)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Docker Setup](#docker-setup)
- [Deployment](#deployment)
- [CI/CD Pipeline](#cicd-pipeline)
- [API Endpoints](#api-endpoints)
- [Environment Variables](#environment-variables)

## ✨ Features

- **CRUD Operations**: Create, Read, Update, and Delete tutorials
- **Search Functionality**: Find tutorials by title
- **Publish Status**: Mark tutorials as published/unpublished
- **RESTful API**: Clean API design with Express.js
- **Modern Frontend**: Angular 15 with Bootstrap styling
- **Containerized**: Docker and Docker Compose ready
- **CI/CD**: Automated deployment with GitHub Actions
- **Reverse Proxy**: Nginx for routing and load balancing

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────┐
│              Nginx (Port 80)                    │
│            Reverse Proxy                        │
└─────────────┬───────────────────┬───────────────┘
              │                   │
              │                   │
    ┌─────────▼─────────┐  ┌─────▼───────────┐
    │   Frontend:80     │  │  Backend:8080   │
    │   (Angular 15)    │  │  (Node.js)      │
    └───────────────────┘  └────────┬────────┘
                                    │
                           ┌────────▼────────┐
                           │  MongoDB:27017  │
                           │   (Database)    │
                           └─────────────────┘
```

## 🛠️ Technologies Used

### Backend
- **Node.js**: JavaScript runtime
- **Express.js**: Web framework
- **Mongoose**: MongoDB ODM
- **CORS**: Cross-origin resource sharing

### Frontend
- **Angular 15**: Frontend framework
- **TypeScript**: Programming language
- **Bootstrap 4**: CSS framework
- **RxJS**: Reactive programming

### DevOps
- **Docker**: Containerization
- **Docker Compose**: Multi-container orchestration
- **Nginx**: Reverse proxy and web server
- **GitHub Actions**: CI/CD automation

### Database
- **MongoDB 6.0**: NoSQL database

## 📁 Project Structure

```
crud-dd-task-mean-app/
├── backend/                    # Node.js/Express backend
│   ├── app/
│   │   ├── config/            # Database configuration
│   │   ├── controllers/       # Request handlers
│   │   ├── models/            # Mongoose models
│   │   └── routes/            # API routes
│   ├── Dockerfile             # Backend Docker image
│   ├── .dockerignore
│   ├── package.json
│   └── server.js              # Entry point
├── frontend/                   # Angular frontend
│   ├── src/
│   │   ├── app/
│   │   │   ├── components/    # Angular components
│   │   │   ├── models/        # TypeScript models
│   │   │   └── services/      # HTTP services
│   │   └── environments/      # Environment configs
│   ├── Dockerfile             # Frontend Docker image
│   ├── nginx.conf             # Nginx config for frontend
│   ├── .dockerignore
│   └── package.json
├── nginx/                      # Reverse proxy configuration
│   └── nginx.conf
├── .github/
│   └── workflows/
│       └── deploy.yml         # CI/CD pipeline
├── docker-compose.yml         # Docker Compose configuration
├── .env.example               # Environment variables template
├── DEPLOYMENT.md              # Detailed deployment guide
├── .gitignore
└── README.md                  # This file
```

## 🚀 Getting Started

### Prerequisites
- Node.js 18+ and npm
- MongoDB (for local development)
- Docker and Docker Compose (for containerized deployment)
- Git

### Local Development Setup

#### 1. Clone the repository
```bash
git clone https://github.com/ShreyasGowda2004/crud-dd-task-mean-app.git
cd crud-dd-task-mean-app
```

#### 2. Backend Setup
```bash
cd backend
npm install

# Update MongoDB connection in app/config/db.config.js if needed
# Start the server
node server.js
```
Backend will run on `http://localhost:8080`

#### 3. Frontend Setup
```bash
cd frontend
npm install

# Start development server
ng serve --port 8081
```
Frontend will run on `http://localhost:8081`

#### 4. Access the application
Open your browser and navigate to `http://localhost:8081`

## 🐳 Docker Setup

### Build and Run with Podman/Docker Compose

#### 1. Create environment file
```bash
cp .env.example .env
# Edit .env and set DOCKER_USERNAME
```

#### 2. Build and start services
```bash
# Using Podman
podman-compose up -d --build

# OR using Docker
docker compose up -d --build
```

#### 3. Access the application
- **Frontend**: http://localhost (or http://localhost:8888 for local testing)
- **Backend API**: http://localhost/api/tutorials
- **Health Check**: http://localhost/health

**Note**: On local Mac with Podman, port 80 may require privileges. Use port 8888 for testing, or deploy to VM for production port 80 access.

#### 4. View logs
```bash
# All services
podman-compose logs -f   # or: docker compose logs -f

# Specific service
podman-compose logs -f backend
podman-compose logs -f frontend
```

#### 5. Stop services
```bash
podman-compose down   # or: docker compose down
```

### Manual Podman/Docker Build

#### Backend
```bash
cd backend
podman build -t docker.io/shreyasgowda2004/mean-backend:latest .
podman run -d -p 8080:8080 \
  -e MONGODB_URI=mongodb://host.docker.internal:27017/dd_db \
  docker.io/shreyasgowda2004/mean-backend:latest
```

#### Frontend
```bash
cd frontend
podman build -t docker.io/shreyasgowda2004/mean-frontend:latest .
podman run -d -p 4200:80 docker.io/shreyasgowda2004/mean-frontend:latest
```

**Note**: Replace `podman` with `docker` if using Docker instead of Podman.

## 📦 Deployment

**✅ DEPLOYED - Live at http://4.240.92.132**

For detailed deployment instructions including VM setup, Docker Hub configuration, and CI/CD setup, see **[DEPLOYMENT.md](./DEPLOYMENT.md)**.

### Quick Deployment Steps

✅ **All steps completed:**

1. **Set up Docker Hub account** ✅ (shreyasgowda2004)
2. **Launch Ubuntu VM** on AWS/Azure ✅ (Azure: 4.240.92.132)
3. **Install Docker and Docker Compose** on VM ✅
4. **Configure GitHub Secrets** ✅:
   - `DOCKER_USERNAME`
   - `DOCKER_PASSWORD`
   - `VM_HOST`
   - `VM_USERNAME`
   - `VM_SSH_KEY`
5. **Push to GitHub** - CI/CD will automatically deploy ✅

## 🔄 CI/CD Pipeline

The GitHub Actions workflow automatically:
1. **Builds** Docker images for backend and frontend
2. **Pushes** images to Docker Hub
3. **Deploys** to VM by:
   - Pulling latest images
   - Stopping old containers
   - Starting new containers
4. **Verifies** deployment success

Triggered on push to `main` or `master` branch.

## 📡 API Endpoints

### Base URL
- **Local**: `http://localhost:8080/api/tutorials`
- **Production**: `http://<vm-ip>/api/tutorials`

### Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/tutorials` | Get all tutorials |
| GET | `/api/tutorials/:id` | Get tutorial by ID |
| POST | `/api/tutorials` | Create new tutorial |
| PUT | `/api/tutorials/:id` | Update tutorial |
| DELETE | `/api/tutorials/:id` | Delete tutorial |
| DELETE | `/api/tutorials` | Delete all tutorials |
| GET | `/api/tutorials?title=keyword` | Search by title |

### Request/Response Examples

#### Create Tutorial
```bash
curl -X POST http://localhost:8080/api/tutorials \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Docker Guide",
    "description": "Complete Docker containerization guide",
    "published": false
  }'
```

#### Get All Tutorials
```bash
curl http://localhost:8080/api/tutorials
```

#### Update Tutorial
```bash
curl -X PUT http://localhost:8080/api/tutorials/<id> \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Updated Title",
    "description": "Updated description",
    "published": true
  }'
```

## 🔐 Environment Variables

### Backend (.env or docker-compose.yml)
```bash
MONGODB_URI=mongodb://mongodb:27017/dd_db
PORT=8080
```

### Frontend (environments/)
Development: `src/environments/environment.ts`
```typescript
export const environment = {
  production: false,
  apiUrl: 'http://localhost:8080/api/tutorials'
};
```

Production: `src/environments/environment.prod.ts`
```typescript
export const environment = {
  production: true,
  apiUrl: '/api/tutorials'
};
```

### Docker Compose
```bash
DOCKER_USERNAME=your-dockerhub-username
```

## 🧪 Testing

### Backend API Testing
```bash
# Health check
curl http://localhost:8080/

# Get all tutorials
curl http://localhost:8080/api/tutorials

# Create tutorial
curl -X POST http://localhost:8080/api/tutorials \
  -H "Content-Type: application/json" \
  -d '{"title":"Test","description":"Test tutorial","published":false}'
```

### Frontend Testing
```bash
cd frontend
npm test
```

## 🐛 Troubleshooting

### Common Issues

1. **MongoDB connection failed**
   - Ensure MongoDB container is running: `docker compose ps`
   - Check logs: `docker compose logs mongodb`

2. **Frontend can't reach backend**
   - Verify Nginx configuration
   - Check backend logs: `docker compose logs backend`
   - Ensure CORS is enabled

3. **Port already in use**
   - Check which process is using the port: `sudo lsof -i :80`
   - Stop the process or change ports in docker-compose.yml

4. **CI/CD pipeline fails**
   - Verify GitHub secrets are set correctly
   - Check GitHub Actions logs
   - Ensure VM is accessible

For more troubleshooting tips, see [DEPLOYMENT.md](./DEPLOYMENT.md#troubleshooting).

## 📊 Monitoring

### Check Container Status
```bash
docker compose ps
docker compose logs -f
docker stats
```

### Application Health
```bash
# Health endpoint
curl http://localhost/health

# API endpoint
curl http://localhost/api/tutorials
```






