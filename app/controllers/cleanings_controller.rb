class CleaningsController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @cleanings = Cleaning.includes(:stroller, :cleaned_by).order(cleaned_at: :desc, created_at: :desc)
    @recent_cleanings = @cleanings.where(
      'cleaned_at >= ? OR (cleaned_at IS NULL AND created_at >= ?)', 
      1.week.ago, 1.week.ago
    ).count
  end

  def new
    @cleaning = Cleaning.new
    @stroller = Stroller.find(params[:stroller_id]) if params[:stroller_id]
  end

  def create
    @cleaning = Cleaning.new(cleaning_params)
    @cleaning.cleaned_by = current_user
    @cleaning.cleaned_at = Time.current

    if @cleaning.save
      redirect_to cleanings_path, notice: 'Nettoyage enregistré avec succès!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def cleaning_params
    params.require(:cleaning).permit(:stroller_id, :cleaning_type, :notes)
  end
end
