class NotificationChannel < ApplicationRecord
  VALID_TYPES = %w[email log].freeze

  validates :channel_type, presence: true, inclusion: { in: VALID_TYPES }
  validate :config_valid_for_type

  scope :active, -> { where(active: true) }
  scope :by_type, ->(type) { where(channel_type: type) }

  def config_hash
    return {} if config.blank?
    JSON.parse(config)
  rescue JSON::ParserError
    {}
  end

  def config_hash=(hash)
    self.config = hash.to_json
  end

  private

  def config_valid_for_type
    return if config.blank?

    begin
      parsed_config = JSON.parse(config)
    rescue JSON::ParserError
      errors.add(:config, "must be valid JSON")
      return
    end

    case channel_type
    when 'email'
      validate_email_config(parsed_config)
    when 'log'
      validate_log_config(parsed_config)
    end
  end

  def validate_email_config(config)
    unless config['email'].present? && config['email'].match?(URI::MailTo::EMAIL_REGEXP)
      errors.add(:config, "must contain a valid email address")
    end
  end

  def validate_log_config(config)
    # Log config can be empty or contain optional settings like log_level
    if config['log_level'].present? && !%w[debug info warn error].include?(config['log_level'])
      errors.add(:config, "log_level must be one of: debug, info, warn, error")
    end
  end
end
