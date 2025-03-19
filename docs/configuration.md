# Langflow Configuration Guide
# Langflow Configuration Guide

## Overview

This document provides a comprehensive guide to configuring Langflow, including all available environment variables, their purposes, and recommended values for different deployment scenarios.

## Configuration Categories

```mermaid
mindmap
  root((Langflow Config))
    Database
      Connection URL
      Cache Type
      Connection Retry
    Server
      Host
      Port
      Workers
      Frontend Path
    Security
      Auto Login
      Superuser Credentials
      API Key Management
    Storage
      Config Directory
      Database Location
      Environment Variables
    Logging
      Log Level
      Log File Path
    Integration
      Store URL
      Webhook URLs
    Caching
      Cache Type
      Redis Settings
```

## Environment Variables

### Core Configuration

| Variable | Purpose | Default | Example | Notes |
|----------|---------|---------|---------|-------|
| `LANGFLOW_CONFIG_DIR` | Base directory for storage | None | `~/.langflow` | Main configuration directory |
| `LANGFLOW_SAVE_DB_IN_CONFIG_DIR` | Database location control | `false` | `true` | Affects database persistence |
| `LANGFLOW_DATABASE_URL` | Database connection string | `sqlite:///./langflow.db` | `postgresql://user:pass@localhost:5432/langflow` | Supports SQLite and PostgreSQL |
| `LANGFLOW_CACHE_TYPE` | Cache implementation type | `memory` | `redis` | Options: async, memory, redis |

### Server Settings

| Variable | Purpose | Default | Example | Notes |
|----------|---------|---------|---------|-------|
| `LANGFLOW_HOST` | Server host address | None | `127.0.0.1` | Binding address |
| `LANGFLOW_PORT` | Server port | None | `7860` | Service port |
| `LANGFLOW_WORKERS` | Worker processes | None | `1` | Number of Uvicorn workers |
| `LANGFLOW_FRONTEND_PATH` | Frontend files location | None | `/path/to/frontend/build` | Static file serving |

### Security Configuration

| Variable | Purpose | Default | Example | Notes |
|----------|---------|---------|---------|-------|
| `LANGFLOW_AUTO_LOGIN` | Enable auto-login | None | `false` | Requires superuser setup if false |
| `LANGFLOW_SUPERUSER` | Admin username | None | `admin` | Required if auto-login is false |
| `LANGFLOW_SUPERUSER_PASSWORD` | Admin password | None | `secure_password` | Required if auto-login is false |
| `LANGFLOW_REMOVE_API_KEYS` | API key security | None | `true` | Removes keys from saved projects |

### Caching Configuration

#### Memory Cache
```mermaid
graph LR
    A[Request] --> B{Cache Type}
    B -->|Memory| C[ThreadingInMemoryCache]
    B -->|Async| D[AsyncInMemoryCache]
    B -->|Redis| E[RedisCache]
```

#### Redis Cache Settings
| Variable | Purpose | Default | Example |
|----------|---------|---------|---------|
| `LANGFLOW_REDIS_HOST` | Redis server host | `localhost` | `redis.example.com` |
| `LANGFLOW_REDIS_PORT` | Redis server port | `6379` | `6380` |
| `LANGFLOW_REDIS_DB` | Redis database number | `0` | `1` |
| `LANGFLOW_REDIS_CACHE_EXPIRE` | Cache expiration (seconds) | `3600` | `7200` |

### Logging Configuration

| Variable | Purpose | Default | Example |
|----------|---------|---------|---------|
| `LANGFLOW_LOG_LEVEL` | Logging verbosity | None | `critical` |
| `LANGFLOW_LOG_FILE` | Log file path | None | `logs/langflow.log` |

### Integration Settings

| Variable | Purpose | Default | Example |
|----------|---------|---------|-------|
| `LANGFLOW_STORE_URL` | Store API endpoint | None | `https://api.langflow.store` |
| `LANGFLOW_DOWNLOAD_WEBHOOK_URL` | Download tracking | None | `https://api.example.com/download` |
| `LANGFLOW_LIKE_WEBHOOK_URL` | Like tracking | None | `https://api.example.com/like` |
| `BACKEND_URL` | Backend service URL | None | `http://localhost:7860/` |

## Deployment Configurations

### Development Environment
```yaml
LANGFLOW_DATABASE_URL=sqlite:///./langflow.db
LANGFLOW_CACHE_TYPE=memory
LANGFLOW_AUTO_LOGIN=true
LANGFLOW_LOG_LEVEL=debug
```

### Production Environment
```yaml
LANGFLOW_DATABASE_URL=postgresql://user:pass@db:5432/langflow
LANGFLOW_CACHE_TYPE=redis
LANGFLOW_AUTO_LOGIN=false
LANGFLOW_SUPERUSER=admin
LANGFLOW_SUPERUSER_PASSWORD=secure_password
LANGFLOW_LOG_LEVEL=error
LANGFLOW_WORKERS=4
```

### Docker Environment
```yaml
LANGFLOW_DATABASE_URL=postgresql://postgres:postgres@db:5432/langflow
LANGFLOW_REDIS_HOST=redis
LANGFLOW_CACHE_TYPE=redis
LANGFLOW_HOST=0.0.0.0
LANGFLOW_PORT=7860
```

## Configuration Best Practices

### Security
1. **Production Deployment**
   - Disable auto-login
   - Use strong superuser passwords
   - Enable API key removal
   - Use HTTPS
   - Implement rate limiting

2. **Database Security**
   - Use PostgreSQL for production
   - Implement regular backups
   - Use connection pooling
   - Set appropriate permissions

3. **Caching Strategy**
   - Use Redis in production
   - Configure appropriate expiration times
   - Implement cache invalidation

### Performance
1. **Worker Configuration**
   ```python
   workers = min(cpu_count() * 2, 8)  # Example calculation
   ```

2. **Cache Settings**
   ```python
   cache_expire = 3600  # 1 hour for standard cache
   cache_expire_long = 86400  # 24 hours for static content
   ```

## Monitoring and Maintenance

### Prometheus Metrics
```yaml
LANGFLOW_PROMETHEUS_PORT=9090
```

### Log Management
```yaml
LANGFLOW_LOG_LEVEL=info
LANGFLOW_LOG_FILE=logs/langflow.log
```

## Troubleshooting

### Common Issues and Solutions

1. **Database Connection Issues**
   ```yaml
   LANGFLOW_DATABASE_CONNECTION_RETRY=true
   ```

2. **Cache Performance Issues**
   - Switch to Redis cache
   - Adjust cache expiration times
   - Monitor cache hit rates

3. **Worker Management**
   - Adjust worker count based on load
   - Monitor worker health
   - Implement graceful shutdowns

## Configuration Updates

To apply configuration changes:

1. Update environment variables
2. Restart the Langflow service
3. Verify changes in logs
4. Monitor system performance

Remember to backup configurations before making changes and test in a staging environment first.