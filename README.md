# Personal Crypto Alert Service

A Ruby on Rails backend service for monitoring cryptocurrency prices and sending notifications when price thresholds are crossed.

## Features

- **Price Alerts**: Create alerts for crypto pairs (e.g., BTC/USDT) with price thresholds (above/below)
- **Multiple Notification Channels**: Email and log files with extensible architecture
- **Real-time Monitoring**: Integration with Binance API for live price updates
- **Alert Management**: Create, update, delete, and validate alerts

## Tech Stack

- Ruby on Rails 7.x (API mode)
- PostgreSQL
- Binance API integration
- Background job processing

## Local Setup

### Requirements
- Ruby 3.1+
- Rails 7.x
- PostgreSQL

### Installation
```bash
git clone https://github.com/UladKonop/personal_crypto_alert_service.git
cd personal_crypto_alert_service

bundle install
rails db:create db:migrate
rails server
```

## API Endpoints

### Alerts
```bash
# Create alert
POST /api/v1/alerts
{
  "symbol": "BTCUSDT",
  "threshold_price": 50000.0,
  "direction": "above",
  "notification_channels": ["email", "log"]
}

# Get alerts
GET /api/v1/alerts

# Update alert
PATCH /api/v1/alerts/:id

# Delete alert
DELETE /api/v1/alerts/:id
```

### Notification Channels
```bash
POST /api/v1/notification_channels
{
  "type": "email",
  "config": { "email": "user@example.com" }
}
```

## Configuration

Create `.env` file:
```env

```
