# ==============================================================================
# Deployment Script for Windows PowerShell
# ==============================================================================
# This script deploys the application using Docker images from Docker Hub
#
# Usage:
#   .\deploy.ps1           - Deploy/update the application
#   .\deploy.ps1 -Stop     - Stop the application
#   .\deploy.ps1 -Logs     - View logs
#   .\deploy.ps1 -Restart  - Restart the application
#   .\deploy.ps1 -Status   - Check application status

param(
    [switch]$Stop,
    [switch]$Restart,
    [switch]$Logs,
    [switch]$Status,
    [switch]$Update,
    [switch]$Cleanup,
    [switch]$Help
)

# Configuration
$ComposeFile = "docker-compose.prod.yml"
$ProjectName = "cicd_prod"

# ==============================================================================
# FUNCTIONS
# ==============================================================================

function Write-Header {
    param([string]$Message)
    Write-Host "===================================" -ForegroundColor Blue
    Write-Host $Message -ForegroundColor Blue
    Write-Host "===================================" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Error-Message {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ $Message" -ForegroundColor Yellow
}

# Check if Docker is running
function Test-Docker {
    try {
        docker info | Out-Null
        Write-Success "Docker is running"
        return $true
    } catch {
        Write-Error-Message "Docker is not running!"
        Write-Host "Please start Docker Desktop"
        return $false
    }
}

# Check if docker-compose is installed
function Test-DockerCompose {
    try {
        docker-compose version | Out-Null
        Write-Success "docker-compose is installed"
        return $true
    } catch {
        Write-Error-Message "docker-compose is not installed!"
        return $false
    }
}

# Deploy the application
function Invoke-Deploy {
    Write-Header "Deploying Application"

    if (-not (Test-Docker)) { exit 1 }
    if (-not (Test-DockerCompose)) { exit 1 }

    Write-Info "Pulling latest images from Docker Hub..."
    docker-compose -f $ComposeFile pull

    Write-Info "Starting services..."
    docker-compose -f $ComposeFile up -d

    Write-Success "Deployment complete!"

    Write-Host ""
    Write-Info "Waiting for services to be healthy..."
    Start-Sleep -Seconds 5

    Show-Status

    Write-Host ""
    Write-Info "Application URLs:"
    Write-Host "  Backend:  http://localhost:5000"
    Write-Host "  Frontend: http://localhost:3000"
    Write-Host ""
    Write-Info "To view logs: .\deploy.ps1 -Logs"
}

# Stop the application
function Invoke-Stop {
    Write-Header "Stopping Application"

    docker-compose -f $ComposeFile down

    Write-Success "Application stopped"
}

# Restart the application
function Invoke-Restart {
    Write-Header "Restarting Application"

    Invoke-Stop
    Invoke-Deploy
}

# Show logs
function Show-Logs {
    Write-Header "Application Logs"

    docker-compose -f $ComposeFile logs -f --tail=100
}

# Show status
function Show-Status {
    Write-Header "Application Status"

    docker-compose -f $ComposeFile ps

    Write-Host ""
    Write-Info "Service Health:"

    # Check backend
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:5000/api/health" -UseBasicParsing -TimeoutSec 5
        Write-Success "Backend is healthy (http://localhost:5000)"
    } catch {
        Write-Error-Message "Backend is not responding"
    }

    # Check frontend
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 5
        Write-Success "Frontend is healthy (http://localhost:3000)"
    } catch {
        Write-Error-Message "Frontend is not responding"
    }
}

# Update images and redeploy
function Invoke-Update {
    Write-Header "Updating Application"

    Write-Info "Pulling latest images..."
    docker-compose -f $ComposeFile pull

    Write-Info "Recreating containers with new images..."
    docker-compose -f $ComposeFile up -d --force-recreate

    Write-Success "Update complete!"

    Show-Status
}

# Clean up everything
function Invoke-Cleanup {
    Write-Header "Cleaning Up"

    $confirmation = Read-Host "This will remove all containers, images, and volumes. Continue? (y/N)"
    if ($confirmation -eq 'y' -or $confirmation -eq 'Y') {
        docker-compose -f $ComposeFile down -v --rmi all
        Write-Success "Cleanup complete"
    } else {
        Write-Info "Cleanup cancelled"
    }
}

# Show help
function Show-Help {
    Write-Host "Deployment Script for CI/CD Project" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage: .\deploy.ps1 [COMMAND]"
    Write-Host ""
    Write-Host "Commands:"
    Write-Host "  (no command)    Deploy/update the application"
    Write-Host "  -Stop           Stop all services"
    Write-Host "  -Restart        Restart all services"
    Write-Host "  -Logs           View application logs (follow mode)"
    Write-Host "  -Status         Show service status and health"
    Write-Host "  -Update         Pull latest images and redeploy"
    Write-Host "  -Cleanup        Remove all containers, images, and volumes"
    Write-Host "  -Help           Show this help message"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\deploy.ps1              # Deploy the application"
    Write-Host "  .\deploy.ps1 -Logs        # View logs"
    Write-Host "  .\deploy.ps1 -Status      # Check if services are running"
    Write-Host "  .\deploy.ps1 -Update      # Update to latest version"
}

# ==============================================================================
# MAIN
# ==============================================================================

if ($Help) {
    Show-Help
} elseif ($Stop) {
    Invoke-Stop
} elseif ($Restart) {
    Invoke-Restart
} elseif ($Logs) {
    Show-Logs
} elseif ($Status) {
    if (Test-Docker) {
        Show-Status
    }
} elseif ($Update) {
    Invoke-Update
} elseif ($Cleanup) {
    Invoke-Cleanup
} else {
    Invoke-Deploy
}
