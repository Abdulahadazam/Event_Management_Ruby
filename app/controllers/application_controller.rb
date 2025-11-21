class ApplicationController < ActionController::Base
  before_action :authenticate_user!, except: [:home, :index, :show]
  helper_method :current_user

end
