class HomeController < ApplicationController
  def index
    @stations = Station.includes(:strollers).all
    @available_strollers_count = Stroller.where(status: 'available').count
    
    # Données pour la carte
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
  end
end
