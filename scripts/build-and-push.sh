#!/bin/bash

# Build and push Docker images to Docker Hub
# Usage: ./scripts/build-and-push.sh <docker-username>

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Docker username is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: Docker username not provided${NC}"
    echo "Usage: ./scripts/build-and-push.sh <docker-username>"
    exit 1
fi

DOCKER_USERNAME=$1

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Building and Pushing Docker Images${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Login to Docker Hub
echo -e "${YELLOW}Logging in to Docker Hub...${NC}"
podman login docker.io

# Build backend image
echo -e "${YELLOW}Building backend image...${NC}"
podman build -t ${DOCKER_USERNAME}/mean-backend:latest ./backend
echo -e "${GREEN}✓ Backend image built successfully${NC}"
echo ""

# Build frontend image
echo -e "${YELLOW}Building frontend image...${NC}"
podman build -t ${DOCKER_USERNAME}/mean-frontend:latest ./frontend
echo -e "${GREEN}✓ Frontend image built successfully${NC}"
echo ""

# Push backend image
echo -e "${YELLOW}Pushing backend image to Docker Hub...${NC}"
podman push ${DOCKER_USERNAME}/mean-backend:latest
echo -e "${GREEN}✓ Backend image pushed successfully${NC}"
echo ""

# Push frontend image
echo -e "${YELLOW}Pushing frontend image to Docker Hub...${NC}"
podman push ${DOCKER_USERNAME}/mean-frontend:latest
echo -e "${GREEN}✓ Frontend image pushed successfully${NC}"
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}All images built and pushed successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Backend image: ${DOCKER_USERNAME}/mean-backend:latest"
echo "Frontend image: ${DOCKER_USERNAME}/mean-frontend:latest"
