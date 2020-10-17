class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token, if: :devise_controller?
  before_action :configure_permitted_parameters, if: :devise_controller?
  protect_from_forgery with: :null_session

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit :sign_up, keys: [:name]
  end
end
