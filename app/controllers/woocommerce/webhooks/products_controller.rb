module Woocommerce
  module Webhooks
    class ProductsController < BaseController
      def create
        product = Product.find_by(id: params.dig(:product, :id))
        Woocommerce::Webhooks::Products::CRUD::Create.(product, params[:product]) if params[:product]

        render nothing: true
      end
    end
  end
end
