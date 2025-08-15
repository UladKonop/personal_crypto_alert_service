require 'net/http'
require 'json'

class BinanceService
  BASE_URL = 'https://api.binance.com'.freeze
  
  class << self
    def current_price(symbol)
      uri = URI("#{BASE_URL}/api/v3/ticker/price?symbol=#{symbol}")
      
      begin
        response = Net::HTTP.get_response(uri)
        
        if response.code == '200'
          data = JSON.parse(response.body)
          data['price'].to_f
        else
          Rails.logger.error "Binance API error: #{response.code} - #{response.body}"
          nil
        end
      rescue => e
        Rails.logger.error "Error fetching price for #{symbol}: #{e.message}"
        nil
      end
    end

    def symbol_exists?(symbol)
      uri = URI("#{BASE_URL}/api/v3/exchangeInfo")
      
      begin
        response = Net::HTTP.get_response(uri)
        
        if response.code == '200'
          data = JSON.parse(response.body)
          symbols = data['symbols'].map { |s| s['symbol'] }
          symbols.include?(symbol)
        else
          false
        end
      rescue => e
        Rails.logger.error "Error checking symbol #{symbol}: #{e.message}"
        false
      end
    end
  end
end
