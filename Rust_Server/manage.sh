#!/bin/bash

# RustDesk Server Management Script
# Provides easy commands to manage your RustDesk server

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

show_usage() {
    echo "RustDesk Server Management Script"
    echo
    echo "Usage: $0 [COMMAND]"
    echo
    echo "Commands:"
    echo "  start      Start the RustDesk server"
    echo "  stop       Stop the RustDesk server"
    echo "  restart    Restart the RustDesk server"
    echo "  status     Show server status"
    echo "  logs       Show server logs"
    echo "  info       Show server connection information"
    echo "  update     Update and rebuild the server"
    echo "  backup     Backup server data"
    echo "  help       Show this help message"
    echo
}

get_server_ip() {
    curl -s ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}' || echo "Unable to determine IP"
}

show_info() {
    SERVER_IP=$(get_server_ip)
    echo
    echo "=================================="
    echo "RustDesk Server Information"
    echo "=================================="
    echo
    echo -e "${BLUE}Server Details:${NC}"
    echo "  Server IP: $SERVER_IP"
    echo "  Status: $(docker-compose ps --services --filter status=running | wc -l)/$(docker-compose ps --services | wc -l) services running"
    echo
    echo -e "${BLUE}Connection Settings for RustDesk Client:${NC}"
    echo "  ID Server: $SERVER_IP:21116"
    echo "  Relay Server: $SERVER_IP:21117"
    echo
    echo -e "${BLUE}Ports:${NC}"
    echo "  21115 (TCP) - Signal Server"
    echo "  21116 (TCP/UDP) - Signal Server"
    echo "  21117 (TCP) - Relay Server"
    echo "  21118 (TCP) - Relay Server"
    echo "  21119 (TCP) - Relay Server"
    echo
}

case "$1" in
    start)
        print_status "Starting RustDesk server..."
        docker-compose up -d
        if [ $? -eq 0 ]; then
            print_success "RustDesk server started successfully!"
            show_info
        else
            print_error "Failed to start RustDesk server"
            exit 1
        fi
        ;;
    
    stop)
        print_status "Stopping RustDesk server..."
        docker-compose down
        if [ $? -eq 0 ]; then
            print_success "RustDesk server stopped successfully!"
        else
            print_error "Failed to stop RustDesk server"
            exit 1
        fi
        ;;
    
    restart)
        print_status "Restarting RustDesk server..."
        docker-compose restart
        if [ $? -eq 0 ]; then
            print_success "RustDesk server restarted successfully!"
            show_info
        else
            print_error "Failed to restart RustDesk server"
            exit 1
        fi
        ;;
    
    status)
        print_status "Checking RustDesk server status..."
        echo
        docker-compose ps
        echo
        docker-compose top
        ;;
    
    logs)
        print_status "Showing RustDesk server logs..."
        docker-compose logs -f --tail=50
        ;;
    
    info)
        show_info
        ;;
    
    update)
        print_status "Updating RustDesk server..."
        docker-compose down
        docker-compose build --no-cache
        docker-compose up -d
        if [ $? -eq 0 ]; then
            print_success "RustDesk server updated successfully!"
            show_info
        else
            print_error "Failed to update RustDesk server"
            exit 1
        fi
        ;;
    
    backup)
        BACKUP_DIR="backup_$(date +%Y%m%d_%H%M%S)"
        print_status "Creating backup in $BACKUP_DIR..."
        mkdir -p "$BACKUP_DIR"
        cp -r data logs "$BACKUP_DIR/"
        tar -czf "${BACKUP_DIR}.tar.gz" "$BACKUP_DIR"
        rm -rf "$BACKUP_DIR"
        print_success "Backup created: ${BACKUP_DIR}.tar.gz"
        ;;
    
    help|--help|-h)
        show_usage
        ;;
    
    "")
        print_error "No command specified"
        echo
        show_usage
        exit 1
        ;;
    
    *)
        print_error "Unknown command: $1"
        echo
        show_usage
        exit 1
        ;;
esac
