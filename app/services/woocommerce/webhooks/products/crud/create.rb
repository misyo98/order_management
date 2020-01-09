module Woocommerce
  module Webhooks
    module Products
      module CRUD
        class Create
          include Woocommerce::Helpers

          def self.call(*attrs)
            new(*attrs).call
          end

          def initialize(product, params)
            @product = product || Product.new
            @params = params
          end

          def call
            product.assign_attributes(product_params(params: params))
            product.save!
          end

          private

          attr_reader :params, :product
        end
      end
    end
  end
end
