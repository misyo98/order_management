module Woocommerce
  module Actions
    module Orders
      class Update
        include Woocommerce::Helpers

        PARAMS_FOR_UPDATE = {
          status:[:completed, :processing].join(','),
          "filter[updated_at_min]" => Date.today,
          "filter[limit]" => OrderApi::ITEMS_LIMIT
        }

        def initialize
          @woocommerce  = Woocommerce::OrderApi.new(params: PARAMS_FOR_UPDATE)
        end

        def call
          perform
        end

        private

        attr_reader :woocommerce

        def perform
          first_page.upto woocommerce.last_page do |index|
            params = woocommerce.filtered_orders(page: index)
            page_ids = item_ids(params: params)
            orders = Order.where(id: page_ids)

            update(attributes: prepare_attributes(params: params), orders: orders)
          end
        end

        def prepare_attributes(params: {})
          params.inject([]) { |array, param| array << form_attributes(params: param); array }
        end

        def form_attributes(params: {})
          attributes = order_params(params: params)
          attributes['billing_attributes'] = billing_params(params: params['billing_address'].merge!('billable_id' => params['id']))
          attributes['shipping_attributes'] = shipping_params(params: params['shipping_address'].merge!('shippable_id' => params['id']))
          attributes['payment_detail_attributes'] = payment_detail_params(params: params['payment_details'].merge!('order_id' => params['id']))

          attributes
        end

        def update(attributes: [], orders: [])
          attributes.each do |attribute|
            order = find_order(id: attribute[:id], orders: orders)
            next unless order
            order.update(attribute)
          end
          PaymentDetail.where(order_id: nil).delete_all
          Woocommerce::Actions::Notes::UpdatePaidOrders.new.call(order_ids: order_without_paid_date_ids(orders: orders))
          puts "Successfully updated #{orders.count} orders!"
        end

        def find_order(id:, orders: [])
          orders.detect { |order| order.id == id.to_i }
        end

        def order_without_paid_date_ids(orders:)
          orders.select { |order| order.paid_date.nil? }.map(&:id)
        end
      end
    end
  end
end
