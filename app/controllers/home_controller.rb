class HomeController < ApplicationController
  def index
    @alerts = Alert.all.order(created_at: :desc)
    @notification_channels = NotificationChannel.all.order(created_at: :desc)
  end
end
