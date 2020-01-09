module Woocommerce
  module Actions
    module Orders
      module RemoveLeftovers
        extend self

        def call
          Billing.where(billable_id: nil, billable_type: 'Order').delete_all
          Shipping.where(shippable_id: nil, shippable_type: 'Order').delete_all
          puts "Orders leftovers removed. Now we have #{Billing.where(billable_id: nil, billable_type: 'Order').count} unsigned Billings
          and #{Shipping.where(shippable_id: nil, shippable_type: 'Order').count} unsigned Shippings."
        end
      end
    end
  end
end
