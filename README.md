# Personal Crypto Alert Service

A Ruby on Rails backend service for monitoring cryptocurrency prices and sending notifications when price thresholds are crossed.

## Features

- **Price Alerts**: Create alerts for crypto pairs (e.g., BTCUSDT) with price thresholds (above/below)
- **Multiple Notification Channels**: Configurable notification channels (email, log) with extensible architecture
- **Real-time Monitoring**: Automated price monitoring using Binance API with background job processing
- **Alert Management**: Full CRUD operations for alerts and notification channels
- **Symbol Validation**: Validates cryptocurrency symbols against Binance API
- **Web Interface**: Simple web UI for managing alerts and notification channels
- **Automated Monitoring**: Cron job integration for continuous price monitoring

## Tech Stack

- **Backend**: Ruby on Rails 7.x (API + Web interface)
- **Database**: PostgreSQL
- **External API**: Binance API for price data
- **Background Jobs**: Rails ActiveJob
- **Scheduling**: Whenever gem for cron jobs
- **Testing**: RSpec

## Architecture

The system consists of two main models:
- **Alert**: Stores price alert configurations with symbol, threshold price, direction, and notification channels
- **NotificationChannel**: Stores notification channel configurations (email, log) with JSON config

## Local Setup

### Requirements
- Ruby 3.1+
- Rails 7.x
- PostgreSQL
- Bundler

### Installation
```bash
git clone https://github.com/UladKonop/personal_crypto_alert_service.git
cd personal_crypto_alert_service

# Install dependencies
bundle install

# Setup database
rails db:create db:migrate

# Seed database (optional)
rails db:seed

# Start server
rails server
```

### Testing the Setup
```bash
# Test Binance API connection
rake alerts:test_binance

# Run manual price monitoring
rake alerts:monitor

# Run tests
bundle exec rspec
```

## API Endpoints

### Alerts API
```bash
# Get all alerts
GET /api/v1/alerts

# Get specific alert
GET /api/v1/alerts/:id

# Create alert
POST /api/v1/alerts
{
  "alert": {
    "symbol": "BTCUSDT",
    "threshold_price": 50000.0,
    "direction": "above",
    "notification_channels": ["email", "log"],
    "active": true
  }
}

# Update alert
PATCH /api/v1/alerts/:id
{
  "alert": {
    "threshold_price": 55000.0,
    "active": false
  }
}

# Delete alert
DELETE /api/v1/alerts/:id
```

### Notification Channels API
```bash
# Get all notification channels
GET /api/v1/notification_channels

# Get specific notification channel
GET /api/v1/notification_channels/:id

# Create email notification channel
POST /api/v1/notification_channels
{
  "notification_channel": {
    "channel_type": "email",
    "config": {
      "email": "user@example.com"
    },
    "active": true
  }
}

# Create log notification channel
POST /api/v1/notification_channels
{
  "notification_channel": {
    "channel_type": "log",
    "config": {
      "log_level": "info"
    },
    "active": true
  }
}

# Update notification channel
PATCH /api/v1/notification_channels/:id

# Delete notification channel
DELETE /api/v1/notification_channels/:id
```

## Web Interface

Access the web interface at `http://localhost:3000`:
- **Home**: Overview and quick actions
- **Alerts**: Manage price alerts (`/alerts`)
- **Notification Channels**: Configure notification channels (`/notification_channels`)

## Background Monitoring

The system uses automated price monitoring:

### Manual Monitoring
```bash
# Run one-time monitoring
rake alerts:monitor
```

### Automated Monitoring (Cron)
The system includes cron job configuration that runs every minute:
```bash
# Update cron jobs
whenever --update-crontab

# Clear cron jobs
whenever --clear-crontab

# View current schedule
whenever
```

## Supported Notification Channels

### Email Notifications
- **Type**: `email`
- **Config**: `{"email": "user@example.com"}`
- **Note**: Currently logs to Rails logger (TODO: implement Action Mailer)

### Log Notifications
- **Type**: `log`
- **Config**: `{"log_level": "info"}` (optional)
- **Levels**: debug, info, warn, error

## Important Notes

1. **Notification Channel Setup**: You must create NotificationChannel records before alerts will send notifications
2. **Alert Lifecycle**: Alerts are automatically deactivated after triggering
3. **Symbol Validation**: All symbols are validated against Binance API
4. **Price Monitoring**: Uses Binance REST API endpoint: `https://api.binance.com/api/v3/ticker/price?symbol=BTCUSDT`

## Development

### Running Tests
```bash
bundle exec rspec
```

### Adding New Notification Channels
1. Add new type to `NotificationChannel::VALID_TYPES`
2. Add validation method in `NotificationChannel` model
3. Add handler in `NotificationService`
4. Add to `Alert::VALID_NOTIFICATION_CHANNELS`
