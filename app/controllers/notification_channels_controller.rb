class NotificationChannelsController < ApplicationController
  before_action :set_notification_channel, only: [:show, :edit, :update, :destroy]

  # GET /notification_channels
  def index
    @notification_channels = NotificationChannel.all.order(created_at: :desc)
  end

  # GET /notification_channels/:id
  def show
  end

  # GET /notification_channels/new
  def new
    @notification_channel = NotificationChannel.new
  end

  # GET /notification_channels/:id/edit
  def edit
  end

  # POST /notification_channels
  def create
    @notification_channel = NotificationChannel.new(notification_channel_params)
    
    if @notification_channel.save
      redirect_to @notification_channel, notice: 'Notification channel was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /notification_channels/:id
  def update
    if @notification_channel.update(notification_channel_params)
      redirect_to @notification_channel, notice: 'Notification channel was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /notification_channels/:id
  def destroy
    @notification_channel.destroy
    redirect_to notification_channels_url, notice: 'Notification channel was successfully deleted.'
  end

  private

  def set_notification_channel
    @notification_channel = NotificationChannel.find(params[:id])
  end

  def notification_channel_params
    permitted_params = params.require(:notification_channel).permit(:channel_type, :active)
    
    # Handle config based on channel type
    config = {}
    channel_type = params[:notification_channel][:channel_type]
    
    case channel_type
    when 'email'
      email = params[:notification_channel][:email]
      config = { email: email } if email.present?
    when 'log'
      log_level = params[:notification_channel][:log_level]
      config = { log_level: log_level } if log_level.present?
    end
    
    permitted_params.merge(config: config.to_json)
  end
end
