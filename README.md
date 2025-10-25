# Self-Hosted Server Services

This repository contains Docker Compose configurations for various self-hosted services. Each service is organized in its own directory with its specific configuration.

## Services Overview

### 🖼️ Immich (Photo Management)
- Located in `/immich/`
- A self-hosted photo and video backup solution
- Features:
  - Machine learning for photo analysis
  - Redis cache for performance
  - PostgreSQL database for metadata storage
  - Supports hardware acceleration for transcoding
- Accessible via port 2283

### 🎬 Jellyfin (Media Server)
- Located in `/jellyfin/`
- A free software media system for managing and streaming media
- Features:
  - Streams movies, TV shows, and music
  - Hardware acceleration support
  - Multi-user support
  - Organized media library
- Accessible via port 8096

### 🔐 Nginx Proxy Manager
- Located in `/nginxProxyManager/`
- Manages reverse proxy configurations with a user-friendly interface
- Features:
  - SSL certificate management
  - Easy proxy host configuration
  - Web interface for management
- Ports:
  - 80 (HTTP)
  - 443 (HTTPS)
  - 81 (Admin panel)

### 🔑 Vaultwarden (Password Manager)
- Located in `/vaultwarden/`
- A lightweight Bitwarden server implementation
- Features:
  - Password management
  - Secure data storage
  - WebSocket support for instant sync
  - User registration system

### 🌐 WireGuard (VPN)
- Located in `/wireGuard/`
- An easy-to-use WireGuard VPN server
- Features:
  - Web-based management interface
  - Easy client configuration
  - Secure VPN access to your network
- Ports:
  - 51820 (WireGuard VPN)
  - 51821 (Web Interface)

## Network Configuration

Most services are configured to use an external Docker network for inter-container communication. This ensures secure and isolated communication between services while allowing them to work together when needed.

## Getting Started

1. Each service directory contains its own `docker-compose.yml` file
2. Configure the environment variables and paths as needed
3. Use `docker-compose up -d` in each directory to start the services
4. Access the services through their respective web interfaces

## Security Notes

- Make sure to change default passwords
- Keep services updated regularly
- Use strong passwords for all admin interfaces
- Consider enabling 2FA where available
- Review and customize access permissions

## Backups

Remember to regularly backup:
- Configuration files
- Data volumes
- Database contents
- SSL certificates