#!/bin/bash

# ActivePieces Launch Script
# This script provides multiple ways to launch the ActivePieces system

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
ENV_FILE="$PROJECT_ROOT/.env"
ENV_EXAMPLE="$PROJECT_ROOT/.env.example"

# Default values
LAUNCH_MODE="dev"
USE_DOCKER=true
GENERATE_SECRETS=true

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_usage() {
    cat << EOF
ActivePieces Launch Script

Usage: $0 [OPTIONS]

Options:
    -m, --mode MODE         Launch mode: dev, prod, docker, local (default: dev)
    -d, --docker            Use Docker Compose (default: true)
    -l, --local             Use local development setup (implies --no-docker)
    --no-docker             Don't use Docker Compose
    --no-secrets            Don't generate missing secrets
    --setup-only            Only setup environment, don't launch
    -h, --help              Show this help message

Examples:
    $0                      # Launch in development mode with Docker
    $0 --local              # Launch locally without Docker
    $0 --mode prod          # Launch in production mode
    $0 --setup-only         # Only setup environment

EOF
}

generate_secrets() {
    log_info "Generating missing secrets in .env file..."

    # Generate encryption key (32 hex characters)
    if ! grep -q "^AP_ENCRYPTION_KEY=" "$ENV_FILE" 2>/dev/null || [ -z "$(grep "^AP_ENCRYPTION_KEY=" "$ENV_FILE" | cut -d'=' -f2)" ]; then
        local encryption_key=$(openssl rand -hex 32)
        if [ -f "$ENV_FILE" ]; then
            sed -i.bak "s/^AP_ENCRYPTION_KEY=$/AP_ENCRYPTION_KEY=$encryption_key/" "$ENV_FILE"
        else
            echo "AP_ENCRYPTION_KEY=$encryption_key" >> "$ENV_FILE"
        fi
        log_success "Generated AP_ENCRYPTION_KEY"
    fi

    # Generate JWT secret
    if ! grep -q "^AP_JWT_SECRET=" "$ENV_FILE" 2>/dev/null || [ -z "$(grep "^AP_JWT_SECRET=" "$ENV_FILE" | cut -d'=' -f2)" ]; then
        local jwt_secret=$(openssl rand -hex 32)
        if [ -f "$ENV_FILE" ]; then
            sed -i.bak "s/^AP_JWT_SECRET=$/AP_JWT_SECRET=$jwt_secret/" "$ENV_FILE"
        else
            echo "AP_JWT_SECRET=$jwt_secret" >> "$ENV_FILE"
        fi
        log_success "Generated AP_JWT_SECRET"
    fi

    # Generate postgres password
    if ! grep -q "^AP_POSTGRES_PASSWORD=" "$ENV_FILE" 2>/dev/null || [ -z "$(grep "^AP_POSTGRES_PASSWORD=" "$ENV_FILE" | cut -d'=' -f2)" ]; then
        local postgres_password=$(openssl rand -hex 16)
        if [ -f "$ENV_FILE" ]; then
            sed -i.bak "s/^AP_POSTGRES_PASSWORD=$/AP_POSTGRES_PASSWORD=$postgres_password/" "$ENV_FILE"
        else
            echo "AP_POSTGRES_PASSWORD=$postgres_password" >> "$ENV_FILE"
        fi
        log_success "Generated AP_POSTGRES_PASSWORD"
    fi
}

setup_environment() {
    log_info "Setting up environment..."

    # Copy .env.example to .env if .env doesn't exist
    if [ ! -f "$ENV_FILE" ]; then
        log_info "Creating .env file from template..."
        cp "$ENV_EXAMPLE" "$ENV_FILE"
        log_success "Created .env file"
    fi

    # Generate secrets if requested
    if [ "$GENERATE_SECRETS" = true ]; then
        generate_secrets
    fi

    # Check for required tools
    if [ "$USE_DOCKER" = true ]; then
        if ! command -v docker &> /dev/null; then
            log_error "Docker is not installed. Please install Docker to use Docker mode."
            exit 1
        fi

        if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
            log_error "Docker Compose is not installed. Please install Docker Compose."
            exit 1
        fi
    else
        # Check for Node.js
        if ! command -v node &> /dev/null; then
            log_error "Node.js is not installed. Please install Node.js to use local mode."
            exit 1
        fi

        # Check for npm
        if ! command -v npm &> /dev/null; then
            log_error "npm is not installed. Please install npm."
            exit 1
        fi

        # Install dependencies if node_modules doesn't exist
        if [ ! -d "$PROJECT_ROOT/node_modules" ]; then
            log_info "Installing dependencies..."
            cd "$PROJECT_ROOT"
            npm install
            log_success "Dependencies installed"
        fi
    fi

    log_success "Environment setup complete"
}

launch_docker_dev() {
    log_info "Launching ActivePieces in development mode with Docker..."
    cd "$PROJECT_ROOT"

    # Build and start services
    if command -v "docker-compose" &> /dev/null; then
        docker-compose up --build -d
    else
        docker compose up --build -d
    fi

    log_success "ActivePieces is running!"
    log_info "Frontend: http://localhost:8080"
    log_info "API: Available through frontend"
    log_info "Use 'docker-compose logs -f' to view logs"
    log_info "Use 'docker-compose down' to stop services"
}

launch_docker_prod() {
    log_info "Launching ActivePieces in production mode with Docker..."
    cd "$PROJECT_ROOT"

    # Build and start services
    if command -v "docker-compose" &> /dev/null; then
        docker-compose -f docker-compose.yml up --build -d
    else
        docker compose -f docker-compose.yml up --build -d
    fi

    log_success "ActivePieces is running in production mode!"
    log_info "Frontend: http://localhost:8080"
    log_info "Use 'docker-compose logs -f' to view logs"
    log_info "Use 'docker-compose down' to stop services"
}

launch_local_dev() {
    log_info "Launching ActivePieces in local development mode..."
    cd "$PROJECT_ROOT"

    # Start all services concurrently
    npm run dev
}

launch_local_backend() {
    log_info "Launching ActivePieces backend services locally..."
    cd "$PROJECT_ROOT"

    # Start backend and engine services
    npm run dev:backend
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--mode)
            LAUNCH_MODE="$2"
            shift 2
            ;;
        -d|--docker)
            USE_DOCKER=true
            shift
            ;;
        -l|--local)
            USE_DOCKER=false
            shift
            ;;
        --no-docker)
            USE_DOCKER=false
            shift
            ;;
        --no-secrets)
            GENERATE_SECRETS=false
            shift
            ;;
        --setup-only)
            SETUP_ONLY=true
            shift
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            print_usage
            exit 1
            ;;
    esac
done

# Main execution
main() {
    log_info "ActivePieces Launch Script Starting..."

    # Setup environment
    setup_environment

    # If setup only, exit here
    if [ "$SETUP_ONLY" = true ]; then
        log_success "Setup complete! Run the script again without --setup-only to launch."
        exit 0
    fi

    # Launch based on mode and docker preference
    case "$LAUNCH_MODE" in
        "dev")
            if [ "$USE_DOCKER" = true ]; then
                launch_docker_dev
            else
                launch_local_dev
            fi
            ;;
        "prod")
            if [ "$USE_DOCKER" = false ]; then
                log_warning "Production mode without Docker is not recommended."
            fi
            launch_docker_prod
            ;;
        "local")
            launch_local_dev
            ;;
        "backend")
            if [ "$USE_DOCKER" = true ]; then
                log_error "Backend-only mode is only available for local development."
                exit 1
            fi
            launch_local_backend
            ;;
        *)
            log_error "Unknown launch mode: $LAUNCH_MODE"
            log_info "Available modes: dev, prod, local, backend"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"