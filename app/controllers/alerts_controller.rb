class AlertsController < ApplicationController
  before_action :set_alert, only: [:show, :edit, :update, :destroy]

  # GET /alerts
  def index
    @alerts = Alert.all.order(created_at: :desc)
  end

  # GET /alerts/:id
  def show
  end

  # GET /alerts/new
  def new
    @alert = Alert.new
  end

  # GET /alerts/:id/edit
  def edit
  end

  # POST /alerts
  def create
    @alert = Alert.new(alert_params)
    
    # Set notification channels properly
    if params[:alert] && params[:alert][:notification_channels].present?
      @alert.notification_channels_array = params[:alert][:notification_channels].reject(&:blank?)
    end
    
    if @alert.save
      redirect_to @alert, notice: 'Alert was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /alerts/:id
  def update
    @alert.assign_attributes(alert_params)
    
    # Set notification channels properly
    if params[:alert] && params[:alert][:notification_channels].present?
      @alert.notification_channels_array = params[:alert][:notification_channels].reject(&:blank?)
    else
      @alert.notification_channels = nil
    end
    
    if @alert.save
      redirect_to @alert, notice: 'Alert was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /alerts/:id
  def destroy
    @alert.destroy
    redirect_to alerts_url, notice: 'Alert was successfully deleted.'
  end

  private

  def set_alert
    @alert = Alert.find(params[:id])
  end

  def alert_params
    params.require(:alert).permit(:symbol, :threshold_price, :direction, :active, notification_channels: [])
  end
end
