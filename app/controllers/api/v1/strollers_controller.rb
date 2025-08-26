class Api::V1::StrollersController < Api::V1::BaseController
  def index
    @strollers = Stroller.includes(:station).all
    
    strollers_data = @strollers.map do |stroller|
      {
        id: stroller.id,
        qr_code: stroller.qr_code,
        status: stroller.status,
        battery_level: stroller.battery_level,
        gps_lat: stroller.gps_lat,
        gps_lng: stroller.gps_lng,
        station: stroller.station ? {
          id: stroller.station.id,
          name: stroller.station.name,
          address: stroller.station.address
        } : nil
      }
    end

    render_json_success(strollers_data)
  end

  def show
    @stroller = Stroller.includes(:station).find(params[:id])
    
    stroller_data = {
      id: @stroller.id,
      qr_code: @stroller.qr_code,
      status: @stroller.status,
      battery_level: @stroller.battery_level,
      gps_lat: @stroller.gps_lat,
      gps_lng: @stroller.gps_lng,
      station: @stroller.station ? {
        id: @stroller.station.id,
        name: @stroller.station.name,
        address: @stroller.station.address,
        gps_lat: @stroller.station.gps_lat,
        gps_lng: @stroller.station.gps_lng
      } : nil
    }

    render_json_success(stroller_data)
  end

  def scan
    qr_code = params[:qr_code]
    @stroller = Stroller.includes(:station).find_by(qr_code: qr_code)
    
    unless @stroller
      return render_json_error("QR code invalide", :not_found)
    end

    unless @stroller.status == 'available'
      return render_json_error("Cette poussette n'est pas disponible", :unprocessable_entity)
    end

    stroller_data = {
      id: @stroller.id,
      qr_code: @stroller.qr_code,
      status: @stroller.status,
      battery_level: @stroller.battery_level,
      gps_lat: @stroller.gps_lat,
      gps_lng: @stroller.gps_lng,
      station: @stroller.station ? {
        id: @stroller.station.id,
        name: @stroller.station.name,
        address: @stroller.station.address
      } : nil
    }

    render_json_success(stroller_data)
  end
end
