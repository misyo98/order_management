module Woocommerce
  class OrderApi < API
    ITEMS_LIMIT = 100
    
    attr_reader :order_id

    private

    def after_initialize(args)
      @params           = args.fetch(:params, {})
      @response_headers = woocommerce.get('orders', params).headers
      @total_items      = response_headers["x-wc-total"].to_i
      @last_page        = count_last_page
      @order_id         = args.fetch(:order_id, nil)
    end
  end
end
