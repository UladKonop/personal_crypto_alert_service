require 'rails_helper'

RSpec.describe Alert, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      alert = Alert.new(
        symbol: 'BTCUSDT',
        threshold_price: 50000.0,
        direction: 'above',
        notification_channels: 'email,log',
        active: true
      )
      expect(alert).to be_valid
    end

    describe 'symbol validation' do
      it 'requires symbol to be present' do
        alert = Alert.new(threshold_price: 50000.0, direction: 'above')
        expect(alert).to_not be_valid
        expect(alert.errors[:symbol]).to include("can't be blank")
      end

      it 'requires symbol to be uppercase letters only' do
        alert = Alert.new(symbol: 'btcusdt', threshold_price: 50000.0, direction: 'above')
        expect(alert).to_not be_valid
        expect(alert.errors[:symbol]).to include("must be uppercase letters only")
      end

      it 'rejects symbols with numbers' do
        alert = Alert.new(symbol: 'BTC123', threshold_price: 50000.0, direction: 'above')
        expect(alert).to_not be_valid
        expect(alert.errors[:symbol]).to include("must be uppercase letters only")
      end
    end

    describe 'threshold_price validation' do
      it 'requires threshold_price to be present' do
        alert = Alert.new(symbol: 'BTCUSDT', direction: 'above')
        expect(alert).to_not be_valid
        expect(alert.errors[:threshold_price]).to include("can't be blank")
      end

      it 'requires threshold_price to be greater than 0' do
        alert = Alert.new(symbol: 'BTCUSDT', threshold_price: -100, direction: 'above')
        expect(alert).to_not be_valid
        expect(alert.errors[:threshold_price]).to include("must be greater than 0")
      end
    end

    describe 'direction validation' do
      it 'requires direction to be present' do
        alert = Alert.new(symbol: 'BTCUSDT', threshold_price: 50000.0)
        expect(alert).to_not be_valid
        expect(alert.errors[:direction]).to include("can't be blank")
      end

      it 'only allows above or below' do
        alert = Alert.new(symbol: 'BTCUSDT', threshold_price: 50000.0, direction: 'invalid')
        expect(alert).to_not be_valid
        expect(alert.errors[:direction]).to include("is not included in the list")
      end
    end

    describe 'notification_channels validation' do
      it 'accepts valid channels' do
        alert = Alert.new(
          symbol: 'BTCUSDT', 
          threshold_price: 50000.0, 
          direction: 'above',
          notification_channels: 'email,log'
        )
        expect(alert).to be_valid
      end

      it 'rejects invalid channels' do
        alert = Alert.new(
          symbol: 'BTCUSDT', 
          threshold_price: 50000.0, 
          direction: 'above',
          notification_channels: 'email,invalid_channel'
        )
        expect(alert).to_not be_valid
        expect(alert.errors[:notification_channels]).to include("contains invalid channels: invalid_channel")
      end
    end
  end

  describe 'scopes' do
    let!(:active_alert) { Alert.create!(symbol: 'BTCUSDT', threshold_price: 50000, direction: 'above', active: true) }
    let!(:inactive_alert) { Alert.create!(symbol: 'ETHUSDT', threshold_price: 3000, direction: 'below', active: false) }

    describe '.active' do
      it 'returns only active alerts' do
        expect(Alert.active).to include(active_alert)
        expect(Alert.active).to_not include(inactive_alert)
      end
    end

    describe '.for_symbol' do
      it 'returns alerts for specific symbol' do
        expect(Alert.for_symbol('BTCUSDT')).to include(active_alert)
        expect(Alert.for_symbol('BTCUSDT')).to_not include(inactive_alert)
      end
    end
  end

  describe '#notification_channels_array' do
    it 'returns array of channels' do
      alert = Alert.new(notification_channels: 'email,log')
      expect(alert.notification_channels_array).to eq(['email', 'log'])
    end

    it 'returns empty array when no channels' do
      alert = Alert.new(notification_channels: nil)
      expect(alert.notification_channels_array).to eq([])
    end

    it 'handles whitespace' do
      alert = Alert.new(notification_channels: 'email, log ')
      expect(alert.notification_channels_array).to eq(['email', 'log'])
    end
  end

  describe '#notification_channels_array=' do
    it 'sets channels from array' do
      alert = Alert.new
      alert.notification_channels_array = ['email', 'log']
      expect(alert.notification_channels).to eq('email,log')
    end
  end

  describe '#triggered_by_price?' do
    let(:alert_above) { Alert.new(threshold_price: 50000, direction: 'above', active: true) }
    let(:alert_below) { Alert.new(threshold_price: 50000, direction: 'below', active: true) }
    let(:inactive_alert) { Alert.new(threshold_price: 50000, direction: 'above', active: false) }

    context 'with above direction' do
      it 'triggers when price is above threshold' do
        expect(alert_above.triggered_by_price?(51000)).to be true
      end

      it 'triggers when price equals threshold' do
        expect(alert_above.triggered_by_price?(50000)).to be true
      end

      it 'does not trigger when price is below threshold' do
        expect(alert_above.triggered_by_price?(49000)).to be false
      end
    end

    context 'with below direction' do
      it 'triggers when price is below threshold' do
        expect(alert_below.triggered_by_price?(49000)).to be true
      end

      it 'triggers when price equals threshold' do
        expect(alert_below.triggered_by_price?(50000)).to be true
      end

      it 'does not trigger when price is above threshold' do
        expect(alert_below.triggered_by_price?(51000)).to be false
      end
    end

    context 'with inactive alert' do
      it 'does not trigger regardless of price' do
        expect(inactive_alert.triggered_by_price?(60000)).to be false
      end
    end
  end
end
