# RustDesk Server Setup

This directory contains everything you need to deploy a RustDesk server on Ubuntu using Docker.

## Quick Start

### 1. Upload Files to Your Ubuntu Server

Transfer the entire `Rust_Server` directory to your Ubuntu server:

```bash
# Using scp (from your local machine)
scp -r Rust_Server/ user@your-server-ip:/home/user/

# Or upload via your preferred method (SFTP, etc.)
```

### 2. Run the Installation Script

On your Ubuntu server, navigate to the directory and run:

```bash
cd Rust_Server
./install.sh
```

That's it! The script will:
- Install Docker and Docker Compose
- Configure the firewall
- Build and start the RustDesk server
- Display connection information

## What Gets Installed

- **Docker Engine** - Container runtime
- **Docker Compose** - Multi-container orchestration
- **RustDesk Server** - Signal and relay servers
- **Firewall Rules** - UFW configured for RustDesk ports

## Server Management

Use the management script for easy server control:

```bash
# Start the server
./manage.sh start

# Stop the server
./manage.sh stop

# Restart the server
./manage.sh restart

# Check status
./manage.sh status

# View logs
./manage.sh logs

# Show connection info
./manage.sh info

# Update server
./manage.sh update

# Create backup
./manage.sh backup
```

## Client Configuration

After installation, configure your RustDesk clients with:

- **ID Server**: `your-server-ip:21116`
- **Relay Server**: `your-server-ip:21117`

## Ports Used

- `21115` (TCP) - Signal Server
- `21116` (TCP/UDP) - Signal Server
- `21117` (TCP) - Relay Server
- `21118` (TCP) - Relay Server
- `21119` (TCP) - Relay Server

## Files Structure

```
Rust_Server/
├── Dockerfile              # Docker image definition
├── docker-compose.yml      # Container orchestration
├── install.sh              # One-click installation
├── manage.sh               # Server management
├── .env                    # Environment variables
├── README.md               # This file
├── data/                   # Server data (created during install)
└── logs/                   # Server logs (created during install)
```

## Troubleshooting

### Check if services are running:
```bash
./manage.sh status
```

### View server logs:
```bash
./manage.sh logs
```

### Manual Docker commands:
```bash
# Start
docker-compose up -d

# Stop
docker-compose down

# Rebuild
docker-compose build --no-cache
```

### Firewall issues:
```bash
# Check UFW status
sudo ufw status

# Manually open ports if needed
sudo ufw allow 21115:21119/tcp
sudo ufw allow 21116/udp
```

### Permission issues:
```bash
# Add user to docker group
sudo usermod -aG docker $USER
# Then logout and login again
```

## Security Notes

- The server runs as a non-root user inside the container
- Firewall is automatically configured
- Data is persisted in local directories
- Regular backups can be created with `./manage.sh backup`

## Updates

To update the RustDesk server:

```bash
./manage.sh update
```

This will rebuild the container with the latest version and restart the services.

## Support

If you encounter issues:

1. Check the logs: `./manage.sh logs`
2. Verify firewall settings: `sudo ufw status`
3. Ensure Docker is running: `sudo systemctl status docker`
4. Check port availability: `netstat -tulpn | grep 2111`

## Environment Variables

You can modify settings in the `.env` file:

- `RUSTDESK_VERSION` - Version to install
- `RUSTDESK_RELAY_SERVER` - Relay server address
- Port configurations
- Logging levels

After changing `.env`, restart the server:
```bash
./manage.sh restart
```
