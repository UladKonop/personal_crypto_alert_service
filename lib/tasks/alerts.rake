namespace :alerts do
  desc "Monitor cryptocurrency prices and trigger alerts"
  task monitor: :environment do
    puts "Starting price monitoring..."
    PriceMonitoringJob.perform_now
    puts "Price monitoring completed."
  end

  desc "Test Binance API connection"
  task test_binance: :environment do
    puts "Testing Binance API connection..."
    
    price = BinanceService.current_price('BTCUSDT')
    if price
      puts "✓ Successfully fetched BTC/USDT price: $#{price}"
    else
      puts "✗ Failed to fetch price"
    end
    
    exists = BinanceService.symbol_exists?('BTCUSDT')
    puts "✓ BTCUSDT exists: #{exists}"
    
    exists = BinanceService.symbol_exists?('FAKESYMBOL')
    puts "✓ FAKESYMBOL exists: #{exists}"
  end
end
