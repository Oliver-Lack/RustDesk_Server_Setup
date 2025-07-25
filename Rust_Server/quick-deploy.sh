#!/bin/bash

# Quick Deploy Script for RustDesk Server
# This is the absolute minimal script - just run this on your Ubuntu server

echo "🚀 RustDesk Server Quick Deploy"
echo "================================"

# Make install script executable if not already
chmod +x install.sh

# Run the installation
./install.sh

echo ""
echo "✅ Deployment complete!"
echo ""
echo "Your RustDesk server is now running!"
echo "Configure your clients with the information shown above."
