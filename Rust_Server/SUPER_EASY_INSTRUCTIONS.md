# SUPER EASY DEPLOYMENT INSTRUCTIONS

## For the Laziest Possible Setup 😴

### Step 1: Upload to Your Ubuntu Server
Upload the entire `Rust_Server` folder to your Ubuntu server.

### Step 2: Run One Command
```bash
cd Rust_Server && ./quick-deploy.sh
```

### Step 3: That's It!
Your RustDesk server will be running. The script will show you the connection details.

---

## What This Does Automatically

✅ Installs Docker  
✅ Installs Docker Compose  
✅ Configures firewall  
✅ Builds RustDesk server  
✅ Starts all services  
✅ Shows you connection info  

## Connection Info Will Look Like:
```
Server IP: YOUR_SERVER_IP
ID Server: YOUR_SERVER_IP:21116
Relay Server: YOUR_SERVER_IP:21117
```

## Management Commands (Optional)
```bash
./manage.sh start    # Start server
./manage.sh stop     # Stop server
./manage.sh info     # Show connection details
./manage.sh logs     # View logs
```

That's literally it. Minimal effort, maximum results! 🎉
