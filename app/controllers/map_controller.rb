class MapController < ApplicationController
  def index
    @stations = Station.includes(:strollers).all
    @strollers = Stroller.includes(:station).all
    
    # Données pour la carte complète
    @stations_json = @stations.map do |station|
      {
        id: station.id,
        name: station.name,
        lat: station.gps_lat.to_f,
        lng: station.gps_lng.to_f,
        capacity: station.capacity,
        total_strollers: station.strollers.count,
        available_strollers: station.strollers.where(status: 'available').count
      }
    end.to_json
    
    @strollers_json = @strollers.map do |stroller|
      next unless stroller.gps_lat && stroller.gps_lng
      
      {
        id: stroller.id,
        qr_code: stroller.qr_code,
        lat: stroller.gps_lat.to_f,
        lng: stroller.gps_lng.to_f,
        status: stroller.status,
        battery_level: stroller.battery_level,
        station_name: stroller.station&.name
      }
    end.compact.to_json
  end
end
