
class ApplicationController < ActionController::Base
  
  allow_browser versions: :modern
  
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
  
  # Redirect to stored location or homepage after successful login
  def after_sign_in_path_for(resource)
    stored_location_for(resource) || root_path
  end
  
  # Store location before requiring authentication
  def store_location_for_authentication
    store_location_for(:user, request.fullpath) if request.get? && !request.xhr?
  end
end