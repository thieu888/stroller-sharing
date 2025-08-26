class RidesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_ride, only: [:show, :end_ride]

  def index
    @current_ride = current_user.rides.where(status: 'in_progress').first
    @recent_rides = current_user.rides.includes(:stroller).order(created_at: :desc).limit(10)
    @total_rides = current_user.rides.count
    @total_cost = current_user.rides.sum(:cost) || 0
  end

  def show
    @stroller = @ride.stroller
    @station = @stroller.station
  end

  def new
    @stroller = Stroller.find(params[:stroller_id]) if params[:stroller_id]
    @ride = current_user.rides.build
  end

  def create
    @ride = current_user.rides.build(ride_params)
    @ride.start_time = Time.current
    @ride.status = 'in_progress'

    if @ride.save
      @ride.stroller.update(status: 'in_use')
      redirect_to @ride, notice: 'Trajet démarré avec succès!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def end_ride
    if @ride.status == 'in_progress'
      @ride.update(
        end_time: Time.current,
        status: 'completed',
        cost: calculate_cost(@ride)
      )
      @ride.stroller.update(status: 'available')
      redirect_to rides_path, notice: 'Trajet terminé avec succès!'
    else
      redirect_to @ride, alert: 'Ce trajet ne peut pas être terminé.'
    end
  end

  private

  def set_ride
    @ride = current_user.rides.find(params[:id])
  end

  def ride_params
    params.require(:ride).permit(:stroller_id, :start_lat, :start_lng)
  end

  def calculate_cost(ride)
    return 0 unless ride.start_time && ride.end_time
    
    duration_minutes = ((ride.end_time - ride.start_time) / 60).ceil
    base_cost = 1.0 # €1 de base
    cost_per_minute = 0.15 # €0.15 par minute
    
    base_cost + (duration_minutes * cost_per_minute)
  end
end
