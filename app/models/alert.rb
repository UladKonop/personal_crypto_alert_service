class Alert < ApplicationRecord
  VALID_DIRECTIONS = %w[above below].freeze
  VALID_NOTIFICATION_CHANNELS = %w[email log].freeze

  validates :symbol, presence: true, format: { with: /\A[A-Z]+\z/, message: "must be uppercase letters only" }
  validates :threshold_price, presence: true, numericality: { greater_than: 0 }
  validates :direction, presence: true, inclusion: { in: VALID_DIRECTIONS }
  validate :notification_channels_valid
  validate :symbol_exists_on_binance, if: :symbol_changed?

  scope :active, -> { where(active: true) }
  scope :for_symbol, ->(symbol) { where(symbol: symbol) }

  def notification_channels_array
    return [] if notification_channels.blank?
    notification_channels.split(',').map(&:strip)
  end

  def notification_channels_array=(channels)
    if channels.is_a?(Array)
      self.notification_channels = channels.join(',')
    else
      self.notification_channels = channels
    end
  end

  def triggered_by_price?(current_price)
    return false unless active?
    
    case direction
    when 'above'
      current_price >= threshold_price
    when 'below'
      current_price <= threshold_price
    else
      false
    end
  end

  private

  def notification_channels_valid
    return if notification_channels.blank?
    
    channels = notification_channels_array
    invalid_channels = channels - VALID_NOTIFICATION_CHANNELS
    
    if invalid_channels.any?
      errors.add(:notification_channels, "contains invalid channels: #{invalid_channels.join(', ')}")
    end
  end

  def symbol_exists_on_binance
    unless BinanceService.symbol_exists?(symbol)
      errors.add(:symbol, "does not exist on Binance")
    end
  rescue => e
    Rails.logger.error "Error validating symbol #{symbol}: #{e.message}"
    # Skip validation error if API is unavailable
  end
end
