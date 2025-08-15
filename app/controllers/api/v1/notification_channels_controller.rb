class Api::V1::NotificationChannelsController < Api::V1::BaseController
  before_action :set_notification_channel, only: [:show, :update, :destroy]

  # GET /api/v1/notification_channels
  def index
    channels = NotificationChannel.all.order(created_at: :desc)
    render_success(channels.map { |channel| channel_json(channel) })
  end

  # GET /api/v1/notification_channels/:id
  def show
    render_success(channel_json(@notification_channel))
  end

  # POST /api/v1/notification_channels
  def create
    channel = NotificationChannel.new(notification_channel_params)
    
    if channel.save
      render_success(channel_json(channel), :created)
    else
      render json: { 
        error: 'Validation failed', 
        details: channel.errors.full_messages 
      }, status: :unprocessable_entity
    end
  end

  # PATCH /api/v1/notification_channels/:id
  def update
    if @notification_channel.update(notification_channel_params)
      render_success(channel_json(@notification_channel))
    else
      render json: { 
        error: 'Validation failed', 
        details: @notification_channel.errors.full_messages 
      }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/notification_channels/:id
  def destroy
    @notification_channel.destroy
    head :no_content
  end

  private

  def set_notification_channel
    @notification_channel = NotificationChannel.find(params[:id])
  end

  def notification_channel_params
    params.require(:notification_channel).permit(:channel_type, :active, config: {})
  end

  def channel_json(channel)
    {
      id: channel.id,
      channel_type: channel.channel_type,
      config: channel.config_hash,
      active: channel.active,
      created_at: channel.created_at,
      updated_at: channel.updated_at
    }
  end
end
