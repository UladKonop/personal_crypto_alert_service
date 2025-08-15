class Api::V1::AlertsController < Api::V1::BaseController
  before_action :set_alert, only: [:show, :update, :destroy]

  # GET /api/v1/alerts
  def index
    alerts = Alert.all.order(created_at: :desc)
    render_success(alerts.map { |alert| alert_json(alert) })
  end

  # GET /api/v1/alerts/:id
  def show
    render_success(alert_json(@alert))
  end

  # POST /api/v1/alerts
  def create
    alert = Alert.new(alert_params)
    
    if alert.save
      render_success(alert_json(alert), :created)
    else
      render json: { 
        error: 'Validation failed', 
        details: alert.errors.full_messages 
      }, status: :unprocessable_entity
    end
  end

  # PATCH /api/v1/alerts/:id
  def update
    if @alert.update(alert_params)
      render_success(alert_json(@alert))
    else
      render json: { 
        error: 'Validation failed', 
        details: @alert.errors.full_messages 
      }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/alerts/:id
  def destroy
    @alert.destroy
    head :no_content
  end

  private

  def set_alert
    @alert = Alert.find(params[:id])
  end

  def alert_params
    params.require(:alert).permit(:symbol, :threshold_price, :direction, :active, notification_channels: [])
  end

  def alert_json(alert)
    {
      id: alert.id,
      symbol: alert.symbol,
      threshold_price: alert.threshold_price,
      direction: alert.direction,
      active: alert.active,
      notification_channels: alert.notification_channels_array,
      created_at: alert.created_at,
      updated_at: alert.updated_at
    }
  end
end
