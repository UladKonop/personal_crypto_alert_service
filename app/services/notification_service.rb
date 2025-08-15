class NotificationService
  class << self
    def send_alert(alert, current_price)
      channels = alert.notification_channels_array
      
      channels.each do |channel_type|
        case channel_type
        when 'email'
          send_email_notification(alert, current_price)
        when 'log'
          send_log_notification(alert, current_price)
        else
          Rails.logger.warn "Unknown notification channel: #{channel_type}"
        end
      end
    end

    private

    def send_email_notification(alert, current_price)
      email_channels = NotificationChannel.active.by_type('email')
      
      email_channels.each do |channel|
        email = channel.config_hash['email']
        next unless email.present?
        
        Rails.logger.info "EMAIL ALERT: Sending to #{email} - #{alert.symbol} #{alert.direction} #{alert.threshold_price}, current: #{current_price}"
        
        # TODO: Implement email sending via Action Mailer
      end
    end

    def send_log_notification(alert, current_price)
      log_channels = NotificationChannel.active.by_type('log')
      
      log_channels.each do |channel|
        log_level = channel.config_hash['log_level'] || 'info'
        message = "PRICE ALERT: #{alert.symbol} crossed #{alert.direction} #{alert.threshold_price} (current: #{current_price})"
        
        case log_level
        when 'debug'
          Rails.logger.debug message
        when 'info'
          Rails.logger.info message
        when 'warn'
          Rails.logger.warn message
        when 'error'
          Rails.logger.error message
        else
          Rails.logger.info message
        end
      end
    end
  end
end
