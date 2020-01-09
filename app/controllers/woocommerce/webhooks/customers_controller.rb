module Woocommerce
  module Webhooks
    class CustomersController < BaseController
      def create
        customer = Customer.find_by(id: params.dig(:customer, :id))
        Woocommerce::Webhooks::Customers::CRUD::Create.(customer, params[:customer]) if params[:customer]

        render nothing: true
      end
    end
  end
end
