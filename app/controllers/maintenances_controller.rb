class MaintenancesController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @maintenances = Maintenance.includes(:stroller, :reported_by).order(created_at: :desc)
    @pending_maintenances = @maintenances.where(status: 'pending').count
    @completed_maintenances = @maintenances.where(status: 'completed').count
  end

  def new
    @maintenance = Maintenance.new
    @stroller = Stroller.find(params[:stroller_id]) if params[:stroller_id]
  end

  def create
    @maintenance = Maintenance.new(maintenance_params)
    @maintenance.reported_by = current_user
    @maintenance.status = 'pending'

    if @maintenance.save
      @maintenance.stroller.update(status: 'maintenance')
      redirect_to maintenances_path, notice: 'Maintenance signalée avec succès!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def maintenance_params
    params.require(:maintenance).permit(:stroller_id, :issue_description)
  end
end
