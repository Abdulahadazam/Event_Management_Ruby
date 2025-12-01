class ApplicationController < ActionController::Base
  
  protect_from_forgery with: :exception

  
  helper_method :current_user

   allow_browser versions: :modern
  
  # Add this line:
  skip_forgery_protection if: -> { request.path.start_with?('/users/auth/') }
end