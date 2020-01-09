class Api::ProfilesController < Api::ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]

  before_action :add_origin_header, only: [:create]

  before_action :authenticate, only: [:create]

  respond_to :json

  def create
    if Customers::ProfileCreator.(params)
      render nothing: true, status: :no_content
    else
      render json: 'Saving Error', status: :unprocessable_entity
    end
  end
end
