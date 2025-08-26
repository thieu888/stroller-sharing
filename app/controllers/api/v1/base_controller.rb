class Api::V1::BaseController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :authenticate_user!
  
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
  rescue_from ActionController::ParameterMissing, with: :bad_request

  private

  def render_json_success(data = {}, status = :ok)
    render json: {
      success: true,
      data: data
    }, status: status
  end

  def render_json_error(message, status = :unprocessable_entity, errors = {})
    render json: {
      success: false,
      message: message,
      errors: errors
    }, status: status
  end

  def not_found
    render_json_error("Ressource non trouvée", :not_found)
  end

  def unprocessable_entity(exception)
    render_json_error("Données invalides", :unprocessable_entity, exception.record.errors)
  end

  def bad_request
    render_json_error("Paramètres manquants", :bad_request)
  end
end
