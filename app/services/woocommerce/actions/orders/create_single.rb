module Woocommerce
  module Actions
    module Orders
      class CreateSingle
        SALES_LOCATION_KEY = 'Location of sales'.freeze
        SALES_PERSON_KEY = 'Sales person'.freeze
        ORDER_META_KEY = 'order_meta'.freeze
        QUIZ_OPTION_KEY = 'Quiz options'.freeze

        include Woocommerce::Helpers

        def initialize(order_id: nil)
          @woocommerce = Woocommerce::OrderApi.new(order_id: order_id)
          @params = @woocommerce.order_by_id(@woocommerce.order_id)
          @order = Order.find_by(id: params['id'])
        end

        def call
          update_order
          fetch_missing_line_items
        end

        private

        attr_reader :params, :order

        def update_order
          order.update(status: params['status'], customer_id: params['customer_id'])
          order.create_billing(billing_params(params: params['billing_address'].merge!('billable_id' => params['id'])))
          order.create_shipping(shipping_params(params: params['shipping_address'].merge!('shippable_id' => params['id'])))
        end

        def fetch_missing_line_items
          raw_items = line_items(params: params['line_items'],
                                 order_id: params['id'],
                                 sales_location: params.dig(ORDER_META_KEY, SALES_LOCATION_KEY),
                                 sales_person: params.dig(ORDER_META_KEY, SALES_PERSON_KEY),
                                 reference: params.dig(ORDER_META_KEY, QUIZ_OPTION_KEY))
          item_ids = order.line_items.pluck(:wp_id)

          line_items = divide_items_by_quantity(item_params: raw_items).inject([]) do |items, item_params|
            item = LineItem.new(item_params)
            if nil.in? item_ids
              items << item unless order.line_items.find_by(name: item.name)
            else
              items << item unless order.line_items.find_by(wp_id: item.wp_id)
            end
            items
          end

          LineItem.import line_items, validate: false
        end
      end
    end
  end
end
