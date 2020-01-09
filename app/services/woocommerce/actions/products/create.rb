module Woocommerce
  module Actions
    module Products
      class Create
        include Woocommerce::Helpers

        def initialize
          @woocommerce = Woocommerce::ProductApi.new()
        end

        def call
          perform
        end

        private

        attr_reader :woocommerce

        def perform
          first_page.upto woocommerce.last_page do |index|
            params = woocommerce.products(page: index)
            new_ids = difference(params: params)

            return if new_ids.empty?

            objects = form_objects(params: params, new_ids: new_ids)
            save_objects(products: objects)
          end
        end

        def difference(params: [])
          page_ids = item_ids(params: params)
          product_ids = Product.where(id: page_ids).pluck(:id)
          page_ids - product_ids
        end

        def form_objects(params: [], new_ids: [])
          products = []

          params.each do |param|
            next unless param['id'].in?(new_ids)

            products << Product.new(product_params(params: param))
          end
          products
        end

        def save_objects(products: [])
          Product.import products
        end
      end
    end
  end
end
