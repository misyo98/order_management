module Woocommerce
  module Actions
    module Customers
      class Create
        include Woocommerce::Helpers

        def initialize
          @woocommerce = Woocommerce::CustomerApi.new()
        end

        def call
          perform
        end

        private

        attr_reader :woocommerce

        def perform
          woocommerce.last_page.downto first_page do |index|
            params = woocommerce.customers(page: index)
            new_ids = difference(params: params)

            return if new_ids.empty?

            customers = form_objects(params: params, new_ids: new_ids)
            save_objects(customers: customers)
          end
        end

        def difference(params: [])
          page_ids = item_ids(params: params)
          customer_ids = Customer.where(id: page_ids).pluck(:id)
          page_ids - customer_ids
        end

        def form_objects(params: [], customers: [], new_ids: [])
          params.each do |param| 
            next unless param['id'].in?(new_ids)

            customers << customer = Customer.new(customer_params(params: param))
            customer.create_billing(billing_params(params: param['billing_address'].merge!('billable_id' => param['id'])))
            customer.create_shipping(shipping_params(params: param['shipping_address'].merge!('shippable_id' => param['id'])))
            customer.set_token
          end
          customers
        end

        def save_objects(customers: [])
          Customer.import customers
        end
      end
    end
  end
end
