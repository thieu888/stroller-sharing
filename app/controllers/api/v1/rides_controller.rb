class Api::V1::RidesController < Api::V1::BaseController
  before_action :set_ride, only: [:show, :end_ride]

  def index
    @current_ride = current_user.rides.where(status: 'in_progress').first
    @recent_rides = current_user.rides.includes(:stroller).order(created_at: :desc).limit(20)
    
    rides_data = {
      current_ride: @current_ride ? ride_json(@current_ride) : nil,
      recent_rides: @recent_rides.map { |ride| ride_json(ride) },
      total_rides: current_user.rides.count,
      total_cost: current_user.rides.sum(:cost) || 0
    }

    render_json_success(rides_data)
  end

  def show
    render_json_success(ride_json(@ride))
  end

  def create
    @stroller = Stroller.find(params[:stroller_id])
    
    unless @stroller.status == 'available'
      return render_json_error("Cette poussette n'est pas disponible")
    end

    # Vérifier si l'utilisateur a déjà un trajet en cours
    current_ride = current_user.rides.where(status: 'in_progress').first
    if current_ride
      return render_json_error("Vous avez déjà un trajet en cours")
    end

    @ride = current_user.rides.build(
      stroller: @stroller,
      start_time: Time.current,
      start_lat: params[:start_lat],
      start_lng: params[:start_lng],
      status: 'in_progress'
    )

    if @ride.save
      @stroller.update(status: 'in_use')
      render_json_success(ride_json(@ride), :created)
    else
      render_json_error("Impossible de démarrer le trajet", :unprocessable_entity, @ride.errors)
    end
  end

  def end_ride
    unless @ride.status == 'in_progress'
      return render_json_error("Ce trajet ne peut pas être terminé")
    end

    @ride.update(
      end_time: Time.current,
      end_lat: params[:end_lat],
      end_lng: params[:end_lng],
      status: 'completed',
      cost: calculate_cost(@ride)
    )

    @ride.stroller.update(
      status: 'available',
      gps_lat: params[:end_lat],
      gps_lng: params[:end_lng]
    )

    render_json_success(ride_json(@ride))
  end

  private

  def set_ride
    @ride = current_user.rides.find(params[:id])
  end

  def ride_json(ride)
    {
      id: ride.id,
      status: ride.status,
      start_time: ride.start_time,
      end_time: ride.end_time,
      start_lat: ride.start_lat,
      start_lng: ride.start_lng,
      end_lat: ride.end_lat,
      end_lng: ride.end_lng,
      cost: ride.cost,
      duration_minutes: ride.end_time && ride.start_time ? ((ride.end_time - ride.start_time) / 60).round : nil,
      stroller: {
        id: ride.stroller.id,
        qr_code: ride.stroller.qr_code,
        battery_level: ride.stroller.battery_level
      }
    }
  end

  def calculate_cost(ride)
    return 0 unless ride.start_time && ride.end_time
    
    duration_minutes = ((ride.end_time - ride.start_time) / 60).ceil
    base_cost = 1.0 # €1 de base
    cost_per_minute = 0.15 # €0.15 par minute
    
    base_cost + (duration_minutes * cost_per_minute)
  end
end
