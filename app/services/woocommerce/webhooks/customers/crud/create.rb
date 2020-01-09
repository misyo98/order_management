module Woocommerce
  module Webhooks
    module Customers
      module CRUD
        class Create
          include Woocommerce::Helpers

          def self.call(*attrs)
            new(*attrs).call
          end

          def initialize(customer, params)
            @customer = customer || Customer.new
            @params = params
          end

          def call
            customer.assign_attributes(prepared_attributes)
            customer.set_token if customer.new_record?
            customer.save!
            clean_after
          end

          private

          attr_reader :params, :customer

          def prepared_attributes
            customer_params(params: params).tap do |attributes|
              attributes['billing_attributes'] = billing_params(params: params['billing_address'].merge!('billable_id' => params['id']))
              attributes['shipping_attributes'] = shipping_params(params: params['shipping_address'].merge!('shippable_id' => params['id']))
            end
          end

          def clean_after
            Billing.where(billable_id: nil, billable_type: 'Customer').delete_all
            Shipping.where(shippable_id: nil, shippable_type: 'Customer').delete_all
          end
        end
      end
    end
  end
end
