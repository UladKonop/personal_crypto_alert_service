class PriceMonitoringJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Starting price monitoring job"
    
    active_alerts = Alert.active.includes(:id)
    alerts_by_symbol = active_alerts.group_by(&:symbol)
    
    alerts_by_symbol.each do |symbol, alerts|
      begin
        current_price = BinanceService.current_price(symbol)
        
        unless current_price
          Rails.logger.warn "Could not fetch price for #{symbol}"
          next
        end
        
        Rails.logger.debug "#{symbol}: #{current_price}"
        
        alerts.each do |alert|
          if alert.triggered_by_price?(current_price)
            Rails.logger.info "Alert triggered: #{alert.id} - #{symbol} #{alert.direction} #{alert.threshold_price}"
            
            NotificationService.send_alert(alert, current_price)
            
            # Deactivate alert after triggering
            alert.update!(active: false)
          end
        end
        
      rescue => e
        Rails.logger.error "Error monitoring #{symbol}: #{e.message}"
      end
    end
    
    Rails.logger.info "Price monitoring job completed"
  end
end
