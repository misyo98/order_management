class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token, if: -> { controller_name == 'sessions' && action_name == 'create' }

  before_action :authenticate_user!
  before_action :clear_cache

  def user_for_paper_trail
    current_user.full_name
  end

  def after_sign_in_path_for(resource)
    if resource.tailor? || current_user.suit_placing?
      root_path
    else
      booking_tool_appointments_path
    end
  end

  protected

  def clear_cache
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "#{1.year.ago}"
  end
end
