module Woocommerce
  module Webhooks
    class OrdersController < BaseController
      def create
        order = Order.find_by(id: params.dig(:order, :id))
        Woocommerce::Webhooks::Orders::CRUD::Create.(order, params[:order]) if params[:order]

        render nothing: true
      end
    end
  end
end
