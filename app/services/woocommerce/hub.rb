module Woocommerce
  module Hub
    extend self

    def create_customers
      Woocommerce::Actions::Customers::Create.new().call
    end

    def update_customers
      Woocommerce::Actions::Customers::Update.new().call
      Woocommerce::Actions::Customers::RemoveLeftovers.call
    end

    def create_orders
      Woocommerce::Actions::Orders::Create.new().call
    end

    def update_orders_statuses
      Woocommerce::Actions::Orders::Update.new().call
      Woocommerce::Actions::Orders::RemoveLeftovers.call
    end

    def update_recent_customers
      Woocommerce::Actions::Customers::UpdateRecent.new().call
      Woocommerce::Actions::Customers::RemoveLeftovers.call
    end

    def create_products
      Woocommerce::Actions::Products::Create.new().call
    end

    def update_recent_products
      Woocommerce::Actions::Products::Update.new().call
    end

    def create_single_order(id)
      Woocommerce::Actions::Orders::CreateSingle.new(order_id: id).call
    end
  end
end
