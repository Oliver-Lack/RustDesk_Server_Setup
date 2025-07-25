#!/bin/bash

# RustDesk Server Installation Script
# This script will install Docker, build and run the RustDesk server

set -e  # Exit on any error

echo "=================================="
echo "RustDesk Server Installation Script"
echo "=================================="
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root for security reasons."
   print_status "Please run as a regular user with sudo privileges."
   exit 1
fi

# Check if sudo is available
if ! command -v sudo &> /dev/null; then
    print_error "sudo is required but not installed. Please install sudo first."
    exit 1
fi

print_status "Starting RustDesk server installation..."

# Update system packages
print_status "Updating system packages..."
sudo apt-get update -y
sudo apt-get upgrade -y

# Install required packages
print_status "Installing required packages..."
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    ufw

# Install Docker
print_status "Installing Docker..."
if ! command -v docker &> /dev/null; then
    # Add Docker's official GPG key
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    # Set up the repository
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker Engine
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Add current user to docker group
    sudo usermod -aG docker $USER
    
    print_success "Docker installed successfully!"
else
    print_success "Docker is already installed!"
fi

# Install Docker Compose (standalone)
print_status "Installing Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    print_success "Docker Compose installed successfully!"
else
    print_success "Docker Compose is already installed!"
fi

# Configure firewall
print_status "Configuring firewall..."
sudo ufw --force enable
sudo ufw allow 22/tcp      # SSH
sudo ufw allow 21115/tcp   # RustDesk hbbs
sudo ufw allow 21116/tcp   # RustDesk hbbs
sudo ufw allow 21116/udp   # RustDesk hbbs
sudo ufw allow 21117/tcp   # RustDesk hbbr
sudo ufw allow 21118/tcp   # RustDesk hbbr
sudo ufw allow 21119/tcp   # RustDesk hbbr

print_success "Firewall configured successfully!"

# Create data and logs directories
print_status "Creating data directories..."
mkdir -p data logs
chmod 755 data logs

# Build and start the RustDesk server
print_status "Building RustDesk server Docker image..."
if [[ "$1" == "--no-build" ]]; then
    print_warning "Skipping Docker build as requested."
else
    docker-compose build
fi

print_status "Starting RustDesk server..."
docker-compose up -d

# Wait for services to start
print_status "Waiting for services to start..."
sleep 10

# Check if services are running
if docker-compose ps | grep -q "Up"; then
    print_success "RustDesk server is running!"
    
    # Get the server IP
    SERVER_IP=$(curl -s ifconfig.me || hostname -I | awk '{print $1}')
    
    echo
    echo "=================================="
    print_success "Installation Complete!"
    echo "=================================="
    echo
    echo -e "${BLUE}Server Information:${NC}"
    echo "  Server IP: $SERVER_IP"
    echo "  RustDesk Ports:"
    echo "    - 21115 (TCP) - Signal Server"
    echo "    - 21116 (TCP/UDP) - Signal Server"
    echo "    - 21117 (TCP) - Relay Server"
    echo "    - 21118 (TCP) - Relay Server"
    echo "    - 21119 (TCP) - Relay Server"
    echo
    echo -e "${BLUE}Client Configuration:${NC}"
    echo "  In your RustDesk client, set:"
    echo "    - ID Server: $SERVER_IP:21116"
    echo "    - Relay Server: $SERVER_IP:21117"
    echo
    echo -e "${BLUE}Management Commands:${NC}"
    echo "  Start server:  docker-compose up -d"
    echo "  Stop server:   docker-compose down"
    echo "  View logs:     docker-compose logs -f"
    echo "  Restart:       docker-compose restart"
    echo
    echo -e "${YELLOW}Note: You may need to logout and login again for Docker group changes to take effect.${NC}"
    
else
    print_error "Failed to start RustDesk server. Check logs with: docker-compose logs"
    exit 1
fi
