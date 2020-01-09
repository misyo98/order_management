module Orders
  module UpdatePaidDate
    extend self

    def call(order_ids:)
      unpaid_order_ids = Order.where(id: order_ids, paid_date: nil)
      Woocommerce::Actions::Notes::UpdatePaidOrders.new().call(order_ids: unpaid_order_ids) if unpaid_order_ids.any?
    end
  end
end