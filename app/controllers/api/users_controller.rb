class Api::UsersController < Api::ApplicationController
  before_action :add_origin_header, only: [:index]
  respond_to :json
  def index
    @users =
      if params[:country].in?(User::WHITELISTED_COUNTRIES)
        User.sales_people_with_country(params[:country])
      else
        User.all
      end

    respond_with @users
  end
end
