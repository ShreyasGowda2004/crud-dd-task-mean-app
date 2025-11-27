#!/bin/bash

# Local development script
# Starts all services locally without Docker

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Starting Local Development Environment${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if MongoDB is running
echo -e "${YELLOW}Checking MongoDB...${NC}"
if ! pgrep -x "mongod" > /dev/null; then
    echo -e "${RED}Warning: MongoDB is not running${NC}"
    echo "Please start MongoDB first:"
    echo "  brew services start mongodb-community  # macOS"
    echo "  sudo systemctl start mongod           # Linux"
    exit 1
fi
echo -e "${GREEN}✓ MongoDB is running${NC}"
echo ""

# Start backend
echo -e "${YELLOW}Starting backend...${NC}"
cd backend
if [ ! -d "node_modules" ]; then
    echo "Installing backend dependencies..."
    npm install
fi

# Start backend in background
node server.js &
BACKEND_PID=$!
echo -e "${GREEN}✓ Backend started (PID: $BACKEND_PID)${NC}"
echo "  URL: http://localhost:8080"
echo ""

# Wait for backend to start
sleep 3

# Start frontend
echo -e "${YELLOW}Starting frontend...${NC}"
cd ../frontend
if [ ! -d "node_modules" ]; then
    echo "Installing frontend dependencies..."
    npm install
fi

echo -e "${GREEN}✓ Frontend starting...${NC}"
echo "  URL: http://localhost:8081"
echo ""

# Start frontend
ng serve --port 8081

# Cleanup function
cleanup() {
    echo ""
    echo -e "${YELLOW}Stopping services...${NC}"
    kill $BACKEND_PID 2>/dev/null || true
    echo -e "${GREEN}Services stopped${NC}"
}

# Register cleanup function
trap cleanup EXIT INT TERM
