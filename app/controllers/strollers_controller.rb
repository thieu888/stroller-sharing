class StrollersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stroller, only: [:show]

  def index
    @strollers = Stroller.includes(:station).all
    @available_strollers = @strollers.where(status: 'available')
    @in_use_strollers = @strollers.where(status: 'in_use')
    
    # Données pour la carte des poussettes
    @strollers_json = @strollers.map do |stroller|
      {
        id: stroller.id,
        qr_code: stroller.qr_code,
        lat: stroller.gps_lat&.to_f || stroller.station&.gps_lat&.to_f,
        lng: stroller.gps_lng&.to_f || stroller.station&.gps_lng&.to_f,
        status: stroller.status,
        battery_level: stroller.battery_level,
        station_name: stroller.station&.name
      }
    end.compact.to_json
  end

  def show
    @station = @stroller.station
    @recent_rides = @stroller.rides.includes(:user).order(created_at: :desc).limit(5)
    
    # Données pour la carte de la poussette
    @stroller_json = {
      id: @stroller.id,
      qr_code: @stroller.qr_code,
      lat: @stroller.gps_lat&.to_f || @station&.gps_lat&.to_f,
      lng: @stroller.gps_lng&.to_f || @station&.gps_lng&.to_f,
      status: @stroller.status,
      battery_level: @stroller.battery_level
    }.to_json
  end

  private

  def set_stroller
    @stroller = Stroller.find(params[:id])
  end
end
