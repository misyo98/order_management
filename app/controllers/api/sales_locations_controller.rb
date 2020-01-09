class Api::SalesLocationsController < Api::ApplicationController
  respond_to :json
  before_action :add_origin_header, only: [:index]
  def index
    @sales_locations = SalesLocation.all
    respond_with @sales_locations
  end
end
