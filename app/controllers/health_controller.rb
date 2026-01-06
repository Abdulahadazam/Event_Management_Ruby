class HealthController < ActionController::Base
  # Simple health check - no authentication, no session, no CSRF
  def show
    render json: { status: "ok" }, status: :ok
  end
end
