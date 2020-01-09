module Woocommerce
  class CustomerApi < API

    ITEMS_LIMIT = 100
    
    private 

    def after_initialize(args)
      @params           = args.fetch(:params, {})
      @response_headers = woocommerce.get('customers', params).headers
      @total_items      = response_headers["x-wc-total"].to_i
      @last_page        = count_last_page
    end
  end
end