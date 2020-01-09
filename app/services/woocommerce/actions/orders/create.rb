# frozen_string_literal: true

module Woocommerce
  module Actions
    module Orders
      class Create
        SALES_LOCATION_KEY = 'Location of sales'
        SALES_PERSON_KEY = 'Sales person'
        ORDER_META_KEY = 'order_meta'
        QUIZ_OPTION_KEY = 'Quiz options'
        ACQUISITION_CHANNEL_KEY = 'Acquisition channel'
        OCCASION_DATE_KEY = 'Occasion date'

        include Woocommerce::Helpers

        def initialize
          @woocommerce = Woocommerce::OrderApi.new()
        end

        def call
          perform
        end

        private

        attr_reader :woocommerce

        def perform
          first_page.upto woocommerce.last_page do |index|
            params = woocommerce.orders(page: index)
            new_ids = difference(params: params)

            return if new_ids.empty?

            objects = form_objects(params: params, new_ids: new_ids)
            save_objects(orders: objects[:orders], line_items: objects[:line_items])
          end
        end

        def difference(params: [])
          page_ids = item_ids(params: params)
          order_ids = Order.where(id: page_ids).pluck(:id)
          page_ids - order_ids
        end

        def form_objects(params: [], new_ids: [])
          orders, line_item_objects = [], []

          params.each do |param|
            next unless param['id'].in?(new_ids)
            orders << order = Order.new(order_params(params: param))
            order.create_billing(billing_params(params: param['billing_address'].merge!('billable_id' => param['id'])))
            order.create_shipping(shipping_params(params: param['shipping_address'].merge!('shippable_id' => param['id'])))
            order.create_payment_detail(payment_detail_params(params: param['payment_details'].merge!('order_id' => param['id'])))

            raw_items = line_items(params: param['line_items'],
                                   order_id: param['id'],
                                   sales_location: param.dig(ORDER_META_KEY, SALES_LOCATION_KEY),
                                   sales_person: param.dig(ORDER_META_KEY, SALES_PERSON_KEY),
                                   reference: param.dig(ORDER_META_KEY, QUIZ_OPTION_KEY),
                                   acquisition_channel: param.dig(ORDER_META_KEY, ACQUISITION_CHANNEL_KEY),
                                   occasion_date: (DateTime.strptime(param.dig(ORDER_META_KEY, OCCASION_DATE_KEY), '%m/%d/%Y') rescue nil) )

            divide_items_by_quantity(item_params: raw_items).each do |line_params|
              item = order.line_items.build(line_params)
              item.state = item.order.processing? || order.completed? ? 'new' : 'payment_pending'
              if item.fabrics.any?
                default_fabric_status(item: item)
              end
              line_item_objects << item
            end
          end
          { orders: orders, line_items: line_item_objects.sort_by(&:order_number) }
        end

        def save_objects(orders: [], line_items: [])
          orders.each do |order|
            order.run_callbacks(:create) { false }
          end

          Order.import orders
          LineItem.import line_items, validate: false
        end
      end
    end
  end
end
