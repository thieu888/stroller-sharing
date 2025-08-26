class Api::V1::StationsController < Api::V1::BaseController
  def index
    @stations = Station.includes(:strollers).all
    
    stations_data = @stations.map do |station|
      {
        id: station.id,
        name: station.name,
        address: station.address,
        gps_lat: station.gps_lat,
        gps_lng: station.gps_lng,
        capacity: station.capacity,
        total_strollers: station.strollers.count,
        available_strollers: station.strollers.where(status: 'available').count,
        strollers: station.strollers.map do |stroller|
          {
            id: stroller.id,
            qr_code: stroller.qr_code,
            status: stroller.status,
            battery_level: stroller.battery_level
          }
        end
      }
    end

    render_json_success(stations_data)
  end

  def show
    @station = Station.includes(:strollers).find(params[:id])
    
    station_data = {
      id: @station.id,
      name: @station.name,
      address: @station.address,
      gps_lat: @station.gps_lat,
      gps_lng: @station.gps_lng,
      capacity: @station.capacity,
      total_strollers: @station.strollers.count,
      available_strollers: @station.strollers.where(status: 'available').count,
      strollers: @station.strollers.map do |stroller|
        {
          id: stroller.id,
          qr_code: stroller.qr_code,
          status: stroller.status,
          battery_level: stroller.battery_level,
          gps_lat: stroller.gps_lat,
          gps_lng: stroller.gps_lng
        }
      end
    }

    render_json_success(station_data)
  end
end
