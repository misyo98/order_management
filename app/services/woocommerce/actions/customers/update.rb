module Woocommerce
  module Actions
    module Customers
      class Update
        include Woocommerce::Helpers

        PARAMS_FOR_UPDATE = {  
          "filter[updated_at_min]" => Date.yesterday, 
          "filter[limit]" => CustomerApi::ITEMS_LIMIT  
        }

        def initialize
          @woocommerce  = Woocommerce::CustomerApi.new(params: PARAMS_FOR_UPDATE)
        end

        def call
          perform
        end

        private

        attr_reader :woocommerce

        def perform
          first_page.upto woocommerce.last_page do |index|
            params = woocommerce.filtered_customers(page: index)
            page_ids = item_ids(params: params)
            customers = Customer.where(id: page_ids)

            update(attributes: prepare_attributes(params: params), customers: customers)
          end
        end

        def prepare_attributes(params: {})
          params.inject([]) { |array, param| array << form_attributes(params: param); array }
        end

        def form_attributes(params: {})
          attributes = customer_params(params: params)
          attributes['billing_attributes'] = billing_params(params: params['billing_address'].merge!('billable_id' => params['id']))
          attributes['shipping_attributes'] = shipping_params(params: params['shipping_address'].merge!('shippable_id' => params['id']))

          attributes
        end

        def update(attributes: [], customers: [])
          attributes.each do |attribute|
            customer = find_customer(id: attribute[:id], customers: customers)
            customer.update(attribute) if customer
          end
        end

        def find_customer(id:, customers: [])
          customers.detect { |customer| customer.id == id }
        end
      end
    end
  end
end