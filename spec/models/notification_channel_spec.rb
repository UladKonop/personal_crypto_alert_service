require 'rails_helper'

RSpec.describe NotificationChannel, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      channel = NotificationChannel.new(
        channel_type: 'email',
        config: '{"email": "test@example.com"}',
        active: true
      )
      expect(channel).to be_valid
    end

    describe 'channel_type validation' do
      it 'requires channel_type to be present' do
        channel = NotificationChannel.new(config: '{}')
        expect(channel).to_not be_valid
        expect(channel.errors[:channel_type]).to include("can't be blank")
      end

      it 'only allows valid types' do
        channel = NotificationChannel.new(channel_type: 'invalid', config: '{}')
        expect(channel).to_not be_valid
        expect(channel.errors[:channel_type]).to include("is not included in the list")
      end

      it 'allows email type' do
        channel = NotificationChannel.new(
          channel_type: 'email',
          config: '{"email": "test@example.com"}'
        )
        expect(channel).to be_valid
      end

      it 'allows log type' do
        channel = NotificationChannel.new(
          channel_type: 'log',
          config: '{}'
        )
        expect(channel).to be_valid
      end
    end

    describe 'config validation' do
      context 'with email type' do
        it 'requires valid email in config' do
          channel = NotificationChannel.new(
            channel_type: 'email',
            config: '{"email": "invalid-email"}'
          )
          expect(channel).to_not be_valid
          expect(channel.errors[:config]).to include("must contain a valid email address")
        end

        it 'requires email field in config' do
          channel = NotificationChannel.new(
            channel_type: 'email',
            config: '{}'
          )
          expect(channel).to_not be_valid
          expect(channel.errors[:config]).to include("must contain a valid email address")
        end

        it 'accepts valid email config' do
          channel = NotificationChannel.new(
            channel_type: 'email',
            config: '{"email": "user@example.com"}'
          )
          expect(channel).to be_valid
        end
      end

      context 'with log type' do
        it 'accepts empty config' do
          channel = NotificationChannel.new(
            channel_type: 'log',
            config: '{}'
          )
          expect(channel).to be_valid
        end

        it 'accepts valid log_level' do
          channel = NotificationChannel.new(
            channel_type: 'log',
            config: '{"log_level": "info"}'
          )
          expect(channel).to be_valid
        end

        it 'rejects invalid log_level' do
          channel = NotificationChannel.new(
            channel_type: 'log',
            config: '{"log_level": "invalid"}'
          )
          expect(channel).to_not be_valid
          expect(channel.errors[:config]).to include("log_level must be one of: debug, info, warn, error")
        end
      end

      it 'rejects invalid JSON' do
        channel = NotificationChannel.new(
          channel_type: 'email',
          config: 'invalid json'
        )
        expect(channel).to_not be_valid
        expect(channel.errors[:config]).to include("must be valid JSON")
      end
    end
  end

  describe 'scopes' do
    let!(:active_channel) { NotificationChannel.create!(channel_type: 'email', config: '{"email": "test@example.com"}', active: true) }
    let!(:inactive_channel) { NotificationChannel.create!(channel_type: 'log', config: '{}', active: false) }

    describe '.active' do
      it 'returns only active channels' do
        expect(NotificationChannel.active).to include(active_channel)
        expect(NotificationChannel.active).to_not include(inactive_channel)
      end
    end

    describe '.by_type' do
      it 'returns channels of specific type' do
        expect(NotificationChannel.by_type('email')).to include(active_channel)
        expect(NotificationChannel.by_type('email')).to_not include(inactive_channel)
      end
    end
  end

  describe '#config_hash' do
    it 'returns parsed JSON config' do
      channel = NotificationChannel.new(config: '{"email": "test@example.com"}')
      expect(channel.config_hash).to eq({"email" => "test@example.com"})
    end

    it 'returns empty hash for blank config' do
      channel = NotificationChannel.new(config: nil)
      expect(channel.config_hash).to eq({})
    end

    it 'returns empty hash for invalid JSON' do
      channel = NotificationChannel.new(config: 'invalid json')
      expect(channel.config_hash).to eq({})
    end
  end

  describe '#config_hash=' do
    it 'sets config as JSON string' do
      channel = NotificationChannel.new
      channel.config_hash = {"email" => "test@example.com"}
      expect(channel.config).to eq('{"email":"test@example.com"}')
    end
  end
end
