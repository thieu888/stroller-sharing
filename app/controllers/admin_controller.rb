class AdminController < ApplicationController
  before_action :authenticate_user!
  
  def dashboard
    @total_users = User.count
    @total_stations = Station.count
    @total_strollers = Stroller.count
    @available_strollers = Stroller.available.count
    @in_use_strollers = Stroller.in_use.count
    @maintenance_strollers = Stroller.needing_maintenance.count
    
    @total_rides = Ride.count
    @active_rides = Ride.where(status: 'in_progress').count
    @completed_rides_today = Ride.where(status: 'completed', created_at: Date.current.beginning_of_day..Date.current.end_of_day).count
    
    @pending_maintenances = Maintenance.where(status: 'pending').count
    @recent_cleanings = Cleaning.where(cleaned_at: 1.week.ago..Time.current).count
    
    @low_battery_strollers = Stroller.low_battery.count
    @revenue_today = Ride.where(status: 'completed', end_time: Date.current.beginning_of_day..Date.current.end_of_day).sum(:cost)
    
    # Données pour les graphiques
    @rides_per_day = Ride.where(created_at: 7.days.ago..Time.current)
                          .group("DATE(created_at)")
                          .count
    
    @strollers_by_status = Stroller.group(:status).count
  end
end
