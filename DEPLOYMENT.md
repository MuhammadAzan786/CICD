# 🚀 Deployment Guide - WSL/Windows

This guide shows you how to deploy your CI/CD application to WSL (Windows Subsystem for Linux).

---

## 📋 Prerequisites

### 1. Docker in WSL
Make sure Docker is running in your WSL environment:

```bash
# Check if Docker is running
docker --version
docker ps

# If Docker is not installed in WSL, install it:
# Follow: https://docs.docker.com/engine/install/ubuntu/
```

### 2. Docker Compose
```bash
# Check if docker-compose is installed
docker-compose --version

# If not installed:
sudo apt update
sudo apt install docker-compose -y
```

---

## 🎯 Quick Start - Deploy to WSL

### Option 1: Using the Deployment Script (Recommended)

The easiest way to deploy:

```bash
# Open WSL terminal
cd /mnt/c/Users/azana/Documents/CICD_PRAC

# Make script executable (if not already)
chmod +x deploy.sh

# Deploy the application
./deploy.sh
```

That's it! The script will:
- ✅ Check if Docker is running
- ✅ Pull latest images from Docker Hub
- ✅ Start all services
- ✅ Show status and URLs

### Option 2: Manual Deployment

If you prefer to run commands manually:

```bash
# Pull latest images from Docker Hub
docker-compose -f docker-compose.prod.yml pull

# Start services
docker-compose -f docker-compose.prod.yml up -d

# Check status
docker-compose -f docker-compose.prod.yml ps
```

---

## 🛠️ Deployment Script Commands

The `deploy.sh` script supports multiple commands:

```bash
# Deploy/update application
./deploy.sh

# Stop application
./deploy.sh stop

# Restart application
./deploy.sh restart

# View logs (real-time)
./deploy.sh logs

# Check status
./deploy.sh status

# Update to latest version from Docker Hub
./deploy.sh update

# Clean up everything
./deploy.sh cleanup

# Show help
./deploy.sh help
```

---

## 💻 Windows PowerShell Deployment

If you want to deploy from Windows PowerShell (not WSL):

```powershell
# Navigate to project directory
cd C:\Users\azana\Documents\CICD_PRAC

# Deploy application
.\deploy.ps1

# Other commands:
.\deploy.ps1 -Stop          # Stop services
.\deploy.ps1 -Restart       # Restart services
.\deploy.ps1 -Logs          # View logs
.\deploy.ps1 -Status        # Check status
.\deploy.ps1 -Update        # Update to latest
.\deploy.ps1 -Cleanup       # Clean up
.\deploy.ps1 -Help          # Show help
```

---

## 🌐 Access Your Application

After successful deployment:

- **Frontend:** http://localhost:3000
- **Backend API:** http://localhost:5000
- **Health Check:** http://localhost:5000/api/health

---

## 🔄 Complete Deployment Workflow

### Step 1: Initial Setup (One Time)

```bash
# Open WSL terminal
cd /mnt/c/Users/azana/Documents/CICD_PRAC

# Ensure Docker is running
docker ps

# If Docker is not running, start it:
sudo service docker start
```

### Step 2: First Deployment

```bash
# Deploy the application
./deploy.sh

# Expected output:
# ✓ Docker is running
# ✓ docker-compose is installed
# Pulling latest images...
# Starting services...
# ✓ Deployment complete!
```

### Step 3: Verify Deployment

```bash
# Check service status
./deploy.sh status

# View logs
./deploy.sh logs

# Test backend
curl http://localhost:5000/api/health

# Test frontend (open browser)
# Visit: http://localhost:3000
```

### Step 4: Update to Latest Version

When you push new changes to GitHub and CI/CD builds new images:

```bash
# Pull latest images and redeploy
./deploy.sh update
```

---

## 📊 Monitoring & Debugging

### View Real-time Logs

```bash
# All services
./deploy.sh logs

# Specific service only
docker-compose -f docker-compose.prod.yml logs -f backend
docker-compose -f docker-compose.prod.yml logs -f frontend
```

### Check Service Status

```bash
./deploy.sh status

# Or manually
docker-compose -f docker-compose.prod.yml ps
```

### Inspect Containers

```bash
# List running containers
docker ps

# Execute commands inside container
docker exec -it my-backend-prod sh
docker exec -it my-frontend-prod sh

# Check container resource usage
docker stats
```

### Health Checks

```bash
# Backend health
curl http://localhost:5000/api/health

# Expected: {"status":"OK","message":"Backend is running"}

# Frontend health
curl http://localhost:3000

# Expected: HTML content
```

---

## 🔧 Troubleshooting

### Issue 1: Docker Not Running

**Error:** `Cannot connect to the Docker daemon`

**Solution:**
```bash
# Start Docker service in WSL
sudo service docker start

# Or if using Docker Desktop, ensure WSL integration is enabled:
# Docker Desktop → Settings → Resources → WSL Integration
# Enable integration for your WSL distro
```

### Issue 2: Port Already in Use

**Error:** `Bind for 0.0.0.0:5000 failed: port is already allocated`

**Solution:**
```bash
# Find what's using the port
sudo lsof -i :5000
sudo lsof -i :3000

# Kill the process or stop existing containers
docker-compose -f docker-compose.prod.yml down

# Or change ports in docker-compose.prod.yml
```

### Issue 3: Images Not Found

**Error:** `manifest for muhammadazan786/my-backend:latest not found`

**Solution:**
```bash
# Ensure CI/CD pipeline has run successfully on GitHub
# Check Docker Hub: https://hub.docker.com/u/muhammadazan786

# If images exist but pull fails, login to Docker Hub
docker login

# Then try again
./deploy.sh
```

### Issue 4: Services Not Healthy

**Error:** Services start but health checks fail

**Solution:**
```bash
# Check logs for errors
./deploy.sh logs

# Restart services
./deploy.sh restart

# Check if services are listening on correct ports
docker exec -it my-backend-prod wget -O- http://localhost:5000/api/health
```

### Issue 5: Can't Access from Browser

**Problem:** Services running but can't access http://localhost:3000

**Solution:**
```bash
# Check if ports are exposed
docker ps

# Check WSL networking
# From Windows, try: http://localhost:3000
# From WSL, try: curl http://localhost:3000

# If using WSL2, you may need to access via WSL IP
ip addr show eth0 | grep inet
# Use the IP shown: http://172.x.x.x:3000
```

---

## 🔄 Update Workflow

### Automatic Updates

When you push changes to GitHub:

1. **GitHub Actions** automatically:
   - Runs tests
   - Builds Docker images
   - Pushes to Docker Hub

2. **Deploy to WSL:**
   ```bash
   ./deploy.sh update
   ```

3. **Verify:**
   ```bash
   ./deploy.sh status
   ```

### Manual Rollback

If new version has issues, rollback to specific version:

```bash
# List available image tags
docker images muhammadazan786/my-backend
docker images muhammadazan786/my-frontend

# Update docker-compose.prod.yml to use specific tag
# Change: muhammadazan786/my-backend:latest
# To: muhammadazan786/my-backend:abc123def (commit SHA)

# Redeploy
docker-compose -f docker-compose.prod.yml up -d
```

---

## 🧹 Cleanup

### Stop Services (Keep Images)

```bash
./deploy.sh stop
```

### Remove Everything

```bash
# This removes containers, images, and networks
./deploy.sh cleanup
```

### Manual Cleanup

```bash
# Stop and remove containers
docker-compose -f docker-compose.prod.yml down

# Remove images
docker rmi muhammadazan786/my-backend:latest
docker rmi muhammadazan786/my-frontend:latest

# Remove unused Docker resources
docker system prune -a
```

---

## 📦 Production Deployment (Other Servers)

To deploy on a production server (AWS, DigitalOcean, etc.):

```bash
# 1. SSH into your server
ssh user@your-server.com

# 2. Install Docker and Docker Compose
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 3. Copy deployment files
scp docker-compose.prod.yml deploy.sh user@your-server.com:~/app/

# 4. Deploy
cd ~/app
chmod +x deploy.sh
./deploy.sh

# 5. Configure firewall (if needed)
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 5000
sudo ufw allow 3000
```

---

## 🔐 Environment Variables (Optional)

To use custom environment variables:

```bash
# Create .env file
cat > .env << EOF
NODE_ENV=production
PORT=5000
VITE_API_URL=http://localhost:5000
EOF

# Update docker-compose.prod.yml to use .env file
# Add under each service:
#   env_file:
#     - .env
```

---

## 📝 Summary

**Quick Commands:**
```bash
./deploy.sh           # Deploy
./deploy.sh status    # Check status
./deploy.sh logs      # View logs
./deploy.sh update    # Update to latest
./deploy.sh stop      # Stop services
```

**URLs:**
- Frontend: http://localhost:3000
- Backend: http://localhost:5000/api/health

**Update Process:**
1. Push code to GitHub
2. Wait for CI/CD to complete
3. Run `./deploy.sh update` in WSL

---

## 🎉 You're Ready!

Your application is now deployed to WSL. Every time you push changes to GitHub, they'll automatically build and you can update with a single command!

For questions or issues, check the Troubleshooting section above.
