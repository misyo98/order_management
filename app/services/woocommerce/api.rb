module Woocommerce
  class API

    attr_reader :response_headers, :last_page, :total_items

    ITEMS_LIMIT = 100

    def initialize(args = {})
      @woocommerce = setup_woocommerce
      after_initialize(args)
    end

    def customers(page:)
      woocommerce.get('customers', { page: page, "filter[limit]" => self.class::ITEMS_LIMIT }).parsed_response['customers']
    end

    def orders(page:)
      woocommerce.get('orders', { page: page, "filter[limit]" => self.class::ITEMS_LIMIT, 'filter[meta]' => true }).parsed_response['orders']
    end

    def order_by_id(id)
      woocommerce.get("orders/#{id}").parsed_response['order']
    end

    def products(page:)
      woocommerce.get('products', { page: page, "filter[limit]" => self.class::ITEMS_LIMIT }).parsed_response['products']
    end

    def order_notes(order_id:)
      woocommerce.get("orders/#{order_id}/notes").parsed_response['order_notes']
    end

    def filtered_orders(page:, options: params.dup)
      woocommerce.get('orders', options.merge!(page: page)).parsed_response['orders']
    end

    def filtered_customers(page:, options: params.dup)
      woocommerce.get('customers', options.merge!(page: page)).parsed_response['customers']
    end

    def filtered_products(page:, options: params.dup)
      woocommerce.get('products', options.merge!(page: page)).parsed_response['products']
    end

    private

    attr_reader :woocommerce, :params

    def setup_woocommerce
      WooCommerce::API.new(
        ENV['website'],
        ENV['customer_key'],
        ENV['customer_secret'],
        verify_ssl: false
      )
    end

    def after_initialize(args)
      @response_headers = nil
      @total_items      = nil
      @last_page        = nil
      @params           = {}
    end

    def count_last_page
      (total_items.to_f / self.class::ITEMS_LIMIT.to_f).ceil
    end
  end
end
