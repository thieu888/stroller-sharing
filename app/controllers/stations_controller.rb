class StationsController < ApplicationController
  before_action :set_station, only: [:show]

  def index
    @stations = Station.includes(:strollers).all
  end

  def show
    @available_strollers = @station.strollers.where(status: 'available')
    @total_strollers = @station.strollers.count
    
    # Données pour la carte de la station
    @station_json = {
      id: @station.id,
      name: @station.name,
      lat: @station.gps_lat.to_f,
      lng: @station.gps_lng.to_f,
      capacity: @station.capacity,
      total_strollers: @total_strollers,
      available_strollers: @available_strollers.count
    }.to_json
    
    # Données des poussettes pour la carte
    @strollers_json = @station.strollers.map do |stroller|
      {
        id: stroller.id,
        qr_code: stroller.qr_code,
        lat: stroller.gps_lat&.to_f || @station.gps_lat.to_f,
        lng: stroller.gps_lng&.to_f || @station.gps_lng.to_f,
        status: stroller.status,
        battery_level: stroller.battery_level
      }
    end.to_json
  end

  private

  def set_station
    @station = Station.find(params[:id])
  end
end
