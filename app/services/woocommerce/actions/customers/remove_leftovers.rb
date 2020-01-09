module Woocommerce
  module Actions
    module Customers
      module RemoveLeftovers
        extend self

        def call
          Billing.where(billable_id: nil, billable_type: 'Customer').delete_all
          Shipping.where(shippable_id: nil, shippable_type: 'Customer').delete_all
          puts "Customers leftovers removed. Now we have #{Billing.where(billable_id: nil, billable_type: 'Customer').count} unsigned Billings
          and #{Shipping.where(shippable_id: nil, shippable_type: 'Customer').count} unsigned Shippings."
        end
      end
    end
  end
end
