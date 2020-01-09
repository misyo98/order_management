module Woocommerce
  module Webhooks
    class BaseController < ApplicationController
      skip_before_filter :verify_authenticity_token, only: :create
      skip_before_action :authenticate_user!
    end
  end
end
