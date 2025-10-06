#!/bin/bash

# ==============================================================================
# Deployment Script for WSL/Linux
# ==============================================================================
# This script deploys the application to WSL using Docker images from Docker Hub
#
# Usage:
#   ./deploy.sh           - Deploy/update the application
#   ./deploy.sh stop      - Stop the application
#   ./deploy.sh logs      - View logs
#   ./deploy.sh restart   - Restart the application
#   ./deploy.sh status    - Check application status

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
COMPOSE_FILE="docker-compose.prod.yml"
PROJECT_NAME="cicd_prod"

# ==============================================================================
# FUNCTIONS
# ==============================================================================

print_header() {
    echo -e "${BLUE}===================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}===================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running!"
        echo "Please start Docker Desktop or Docker daemon"
        exit 1
    fi
    print_success "Docker is running"
}

# Check if docker-compose is installed
check_docker_compose() {
    if ! command -v docker-compose &> /dev/null; then
        print_error "docker-compose is not installed!"
        exit 1
    fi
    print_success "docker-compose is installed"
}

# Deploy the application
deploy() {
    print_header "Deploying Application"

    check_docker
    check_docker_compose

    print_info "Pulling latest images from Docker Hub..."
    docker-compose -f $COMPOSE_FILE pull

    print_info "Starting services..."
    docker-compose -f $COMPOSE_FILE up -d

    print_success "Deployment complete!"

    echo ""
    print_info "Waiting for services to be healthy..."
    sleep 5

    show_status

    echo ""
    print_info "Application URLs:"
    echo "  Backend:  http://localhost:5000"
    echo "  Frontend: http://localhost:3000"
    echo ""
    print_info "To view logs: ./deploy.sh logs"
}

# Stop the application
stop() {
    print_header "Stopping Application"

    docker-compose -f $COMPOSE_FILE down

    print_success "Application stopped"
}

# Restart the application
restart() {
    print_header "Restarting Application"

    stop
    deploy
}

# Show logs
show_logs() {
    print_header "Application Logs"

    docker-compose -f $COMPOSE_FILE logs -f --tail=100
}

# Show status
show_status() {
    print_header "Application Status"

    docker-compose -f $COMPOSE_FILE ps

    echo ""
    print_info "Service Health:"

    # Check backend
    if curl -s http://localhost:5000/api/health > /dev/null 2>&1; then
        print_success "Backend is healthy (http://localhost:5000)"
    else
        print_error "Backend is not responding"
    fi

    # Check frontend
    if curl -s http://localhost:3000 > /dev/null 2>&1; then
        print_success "Frontend is healthy (http://localhost:3000)"
    else
        print_error "Frontend is not responding"
    fi
}

# Update images and redeploy
update() {
    print_header "Updating Application"

    print_info "Pulling latest images..."
    docker-compose -f $COMPOSE_FILE pull

    print_info "Recreating containers with new images..."
    docker-compose -f $COMPOSE_FILE up -d --force-recreate

    print_success "Update complete!"

    show_status
}

# Clean up everything (containers, images, volumes)
cleanup() {
    print_header "Cleaning Up"

    read -p "This will remove all containers, images, and volumes. Continue? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker-compose -f $COMPOSE_FILE down -v --rmi all
        print_success "Cleanup complete"
    else
        print_info "Cleanup cancelled"
    fi
}

# Show help
show_help() {
    echo "Deployment Script for CI/CD Project"
    echo ""
    echo "Usage: ./deploy.sh [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  (no command)    Deploy/update the application"
    echo "  stop            Stop all services"
    echo "  restart         Restart all services"
    echo "  logs            View application logs (follow mode)"
    echo "  status          Show service status and health"
    echo "  update          Pull latest images and redeploy"
    echo "  cleanup         Remove all containers, images, and volumes"
    echo "  help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./deploy.sh              # Deploy the application"
    echo "  ./deploy.sh logs         # View logs"
    echo "  ./deploy.sh status       # Check if services are running"
    echo "  ./deploy.sh update       # Update to latest version"
}

# ==============================================================================
# MAIN
# ==============================================================================

case "${1:-deploy}" in
    deploy)
        deploy
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    logs)
        show_logs
        ;;
    status)
        check_docker
        show_status
        ;;
    update)
        update
        ;;
    cleanup)
        cleanup
        ;;
    help)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
