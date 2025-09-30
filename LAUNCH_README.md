# ActivePieces Launch Guide

This guide explains how to use the `launch.sh` script to run the ActivePieces system.

## Quick Start

### Using Docker (Recommended)

```bash
# Launch in development mode (default)
./launch.sh

# Launch in production mode
./launch.sh --mode prod

# Only setup environment (don't launch)
./launch.sh --setup-only
```

### Local Development (Without Docker)

```bash
# Launch locally (requires Node.js and npm)
./launch.sh --local

# Launch only backend services locally
./launch.sh --mode backend --local
```

## Launch Modes

### Development Mode (`dev`)
- **Docker**: Starts all services using Docker Compose
- **Local**: Starts frontend, backend, and engine concurrently using npm scripts
- **Default mode** for both Docker and local

### Production Mode (`prod`)
- Only available with Docker
- Optimized for production deployment
- Use `--mode prod` with Docker

### Local Mode (`local`)
- Runs entirely on local machine
- Requires Node.js, npm, and dependencies
- Useful for development without Docker

### Backend Mode (`backend`)
- Only runs backend and engine services
- Requires local development setup
- Useful for API-only development

## Command Line Options

| Option | Description |
|--------|-------------|
| `-m, --mode MODE` | Launch mode: dev, prod, local, backend |
| `-d, --docker` | Use Docker Compose (default) |
| `-l, --local` | Use local development setup |
| `--no-docker` | Don't use Docker Compose |
| `--no-secrets` | Don't generate missing secrets |
| `--setup-only` | Only setup environment, don't launch |
| `-h, --help` | Show help message |

## What Happens During Setup

The launch script automatically:

1. **Creates `.env` file** from `.env.example` if it doesn't exist
2. **Generates missing secrets**:
   - `AP_ENCRYPTION_KEY` (32 hex characters)
   - `AP_JWT_SECRET` (32 hex characters)
   - `AP_POSTGRES_PASSWORD` (16 hex characters)
3. **Validates environment** and required tools
4. **Installs dependencies** (for local mode)

## Environment Variables

The system uses these key environment variables (configured in `.env`):

- `AP_FRONTEND_URL`: Frontend URL (default: http://localhost:8080)
- `AP_POSTGRES_DATABASE`: Database name (default: activepieces)
- `AP_REDIS_HOST`: Redis host (default: redis)
- `AP_EXECUTION_MODE`: Execution mode (default: UNSANDBOXED)
- `AP_TELEMETRY_ENABLED`: Enable telemetry (default: true)

## Accessing ActivePieces

After successful launch:

- **Frontend**: http://localhost:8080
- **API**: Available through the frontend
- **Database**: PostgreSQL on port 5432
- **Cache**: Redis on port 6379

## Logs and Management

### Docker Mode
```bash
# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Restart services
docker-compose restart
```

### Local Mode
- Services run in foreground with colored output
- Use `Ctrl+C` to stop services
- Logs are displayed in real-time

## Troubleshooting

### Common Issues

1. **Port already in use**
   - Change ports in `.env` file or stop conflicting services

2. **Permission denied**
   - Make sure `launch.sh` is executable: `chmod +x launch.sh`

3. **Docker not found**
   - Install Docker and Docker Compose
   - Or use `--local` flag for local development

4. **Node modules not found**
   - Run `./launch.sh --local` to install dependencies

### Getting Help

```bash
# Show all options
./launch.sh --help

# Check if script is executable
ls -la launch.sh
```

## Development Workflow

1. **First time setup**:
   ```bash
   ./launch.sh --setup-only
   ```

2. **Development**:
   ```bash
   ./launch.sh --local
   ```

3. **Production deployment**:
   ```bash
   ./launch.sh --mode prod
   ```

The launch script provides a unified interface for all ActivePieces deployment scenarios, making it easy to get started and manage the system across different environments.