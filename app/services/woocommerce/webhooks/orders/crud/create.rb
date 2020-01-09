# frozen_string_literal: true

module Woocommerce
  module Webhooks
    module Orders
      module CRUD
        class Create
          SALES_LOCATION_KEY = 'Location of sale'
          SALES_PERSON_KEY = 'Sales person'
          ORDER_META_KEY = 'order_meta'
          QUIZ_OPTION_KEY = 'Quiz options'
          NEW_STATUS = 'new'
          PAYMENT_PENDING_STATUS = 'payment_pending'
          ACQUISITION_CHANNEL_KEY = 'Acquisition channel'
          OCCASION_DATE_KEY = 'Occasion date'

          include Woocommerce::Helpers

          def self.call(*attrs)
            new(*attrs).call
          end

          def initialize(order, params)
            @order = order || Order.new
            @params = params
          end

          def call
            order.assign_attributes(prepared_attributes)
            assign_line_items if order.new_record?
            update_line_item_prices if order.persisted?
            order.save(validate: false)
            clean_after

            Woocommerce::Actions::Notes::UpdatePaidOrders.new.call(order_ids: [order.id]) if order.paid_date.blank?
          end

          private

          attr_reader :params, :order

          def prepared_attributes
            order_params(params: params).tap do |attributes|
              attributes['billing_attributes'] = billing_params(params: params['billing_address'].merge!('billable_id' => params['id']))
              attributes['shipping_attributes'] = shipping_params(params: params['shipping_address'].merge!('shippable_id' => params['id']))
              attributes['payment_detail_attributes'] = payment_detail_params(params: params['payment_details'].merge!('order_id' => params['id']))
            end
          end

          def update_line_item_prices
            divide_items_by_quantity(item_params: params['line_items']).each do |item|
              LineItem.where(wp_id: item['id']).update_all(
                subtotal: to_cents(price: item['subtotal']),
                subtotal_tax: to_cents(price: item['subtotal_tax']),
                total: to_cents(price: item['total']),
                total_tax: to_cents( price: item['total_tax']),
                price: to_cents(price: item['price']))
            end
          end

          def assign_line_items
            raw_items =
              line_items(params: params['line_items'],
                         order_id: params['id'],
                         sales_location: params[SALES_LOCATION_KEY],
                         sales_person: params[SALES_PERSON_KEY],
                         reference: params[QUIZ_OPTION_KEY],
                         acquisition_channel: params[ACQUISITION_CHANNEL_KEY],
                         occasion_date: (DateTime.strptime(params[OCCASION_DATE_KEY], '%m/%d/%Y') rescue nil))

            divide_items_by_quantity(item_params: raw_items).each do |line_params|
              item = order.line_items.build(line_params)
              item.state = order.processing? || order.completed? ? NEW_STATUS : PAYMENT_PENDING_STATUS
              if item.fabrics.any?
                default_fabric_status(item: item)
              end
            end
          end

          def clean_after
            Billing.where(billable_id: nil, billable_type: 'Order').delete_all
            Shipping.where(shippable_id: nil, shippable_type: 'Order').delete_all
            PaymentDetail.where(order_id: nil).delete_all
          end
        end
      end
    end
  end
end
