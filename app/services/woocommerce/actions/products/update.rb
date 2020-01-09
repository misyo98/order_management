module Woocommerce
  module Actions
    module Products
      class Update
        include Woocommerce::Helpers

        PARAMS_FOR_UPDATE = { 
          "filter[updated_at_min]" => Date.today - 10.days, 
          "filter[limit]" => ProductApi::ITEMS_LIMIT  
          }

        def initialize
          @woocommerce  = Woocommerce::ProductApi.new(params: PARAMS_FOR_UPDATE)
        end

        def call
          perform
        end

        private

        attr_reader :woocommerce

        def perform
          first_page.upto woocommerce.last_page do |index|
            params = woocommerce.filtered_products(page: index)
            page_ids = item_ids(params: params)
            products = Product.where(id: page_ids)

            update(attributes: prepare_attributes(params: params), products: products)
          end
        end

        def prepare_attributes(params: {})
          params.inject([]) { |array, param| array << form_attributes(params: param); array }
        end

        def form_attributes(params: {})
          product_params(params: params)
        end

        def update(attributes: [], products: [])
          attributes.each do |attribute|
            product = find_product(id: attribute[:id], products: products)
            next unless product
            
            product.update(attribute)
          end
          puts "Successfully updated #{products.count} products!"
        end

        def find_product(id:, products: [])
          products.detect { |product| product.id == id }
        end
      end
    end
  end
end
