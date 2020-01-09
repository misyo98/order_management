module Woocommerce
  module Helpers
    GRAVITY_FABRIC_CODE_KEY = 'Gravity Fabric Code'.freeze
    FABRIC_CODE_KEY = 'Fabric Code'.freeze
    FABRIC_CODE_OTHER_KEY = 'Fabric Code - Other'.freeze
    FABRIC_CODE_OTHER_VALUE = '=== OTHER ==='.freeze
    FABRIC_CODE_SEPARATOR = ' '.freeze
    PRODUCT_CATEGORY_SEPARATOR = ' '.freeze
    GIFT_CARD_CATEGORY = 'GIFT CARD'.freeze
    GIFT_WORD = 'gift'.freeze
    NON_CUSTOM_CATEGORY = 'NON-CUSTOM'.freeze

    def customer_params(params: {})
      {
        id:                 params['id'],
        created_at:         params['created_at'],
        email:              params['email'],
        first_name:         resolve_first_name(params: params),
        last_name:          resolve_last_name(params: params),
        username:           params['username'],
        last_order_id:      params['last_order_id'],
        orders_count:       params['orders_count'],
        total_spent:        params['total_spent']
      }
    end

    def order_params(params: {})
      {
        id:                         params['id'],
        number:                     params["order_number"],
        customer_id:                params["customer_id"],
        created_at:                 params["created_at"],
        updated_at:                 params["updated_at"],
        completed_at:               params["completed_at"],
        status:                     to_status(status: params["status"]),
        currency:                   params["currency"],
        total:                      to_cents(price: params["total"]),
        subtotal:                   to_cents(price: params["subtotal"]),
        total_line_items_quantity:  params["total_line_items_quantity"],
        total_tax:                  to_cents(price: params["total_tax"]),
        total_shipping:             to_cents(price: params["total_shipping"]),
        cart_tax:                   to_cents(price: params["cart_tax"]),
        shipping_tax:               to_cents(price: params["shipping_tax"]),
        total_discount:             to_cents(price: params["total_discount"]),
        shipping_methods:           params["shipping_methods"],
        note:                       params["note"],
        customer_ip:                params["customer_ip"],
        customer_user_agent:        params["customer_user_agent"],
        view_order_url:             params["view_order_url"],
        shipping_lines:             params["shipping_lines"],
        tax_lines:                  params["tax_lines"],
        fee_lines:                  params["fee_lines"],
        coupon_lines:               params["coupon_lines"]
      }
    end

    def payment_detail_params(params:)
      {
        order_id:         params["order_id"],
        method_id:        params["method_id"],
        method_title:     params["method_title"],
        paid:             params["paid"],
        transaction_id:   params["transaction_id"]
      }
    end

    def line_items(params:, order_id:, sales_location:'', sales_person:'', reference: '', acquisition_channel: '', occasion_date: '')
      extra_params = { 'order_id'       => order_id,
                       'reference'      => reference,
                       'sales_location' => sales_location,
                       'sales_person'   => sales_person,
                       'acquisition_channel' => acquisition_channel,
                       'occasion_date' => occasion_date }
      array = params.collect do |param|
        # decode html special chars
        param['meta']&.map do |meta|
          meta['value'] = Nokogiri::HTML.parse(meta['value']).text
        end
        line_item_params(params: param.merge!(extra_params))
      end
      array
    end

    def billing_params(params: {})
      {
        billable_id:    params['billable_id'],
        first_name:     params['first_name'],
        last_name:      params['last_name'],
        company:        params['company'],
        address_1:      params['address_1'],
        address_2:      params['address_2'],
        city:           params['city'],
        state:          params['state'],
        postcode:       params['postcode'],
        country:        params['country'],
        email:          params['email'],
        phone:          params['phone']
      }
    end

    def shipping_params(params: {})
      {
        shippable_id:    params['shippable_id'],
        first_name:      params['first_name'],
        last_name:       params['last_name'],
        company:         params['company'],
        address_1:       params['address_1'],
        address_2:       params['address_2'],
        city:            params['city'],
        state:           params['state'],
        postcode:        params['postcode'],
        country:         params['country']
      }
    end

    def line_item_params(params:)
      {
        order_id:             params['order_id'],
        subtotal:             to_cents(price: params["subtotal"]),
        subtotal_tax:         to_cents(price: params["subtotal_tax"]),
        total:                to_cents(price: params["total"]),
        total_tax:            to_cents(price: params["total_tax"]),
        price:                to_cents(price: params["price"]),
        quantity:             params["quantity"],
        tax_class:            params["tax_class"],
        name:                 params["name"],
        product_id:           params["product_id"],
        sku:                  params["sku"],
        meta:                 resolve_meta(params["meta"]),
        variations:           params["variations"],
        sales_location_id:    find_sales_location(params['sales_location']),
        sales_person_id:      find_sales_person(params['sales_person']),
        reference:            params['reference'],
        wp_id:                params['id'],
        acquisition_channel:  params['acquisition_channel'],
        occasion_date:        params['occasion_date']
      }
    end

    def product_params(params:)
      {
        id:             params['id'],
        title:          params['title'],
        type_product:   params['type'],
        status:         params['status'],
        permalink:      params['permalink'],
        sku:            params['sku'],
        price:          params['price'],
        regular_price:  params['regular_price'],
        sale_price:     params['sale_price'],
        total_sales:    params['total_sales'],
        category:       resolve_category(params: params),
        created_at:     params['created_at'],
        updated_at:     params['updated_at']
      }
    end

    def item_ids(params: [])
      params.inject([]) { |array, params| array << params['id']; array }
    end

    def first_page
      1
    end

    def divide_items_by_quantity(item_params:)
      item_params.inject([]) do |array, item|
        item[:quantity].times do |index|
          new_item = item.deep_dup
          new_item[:quantity] = 1
          new_item[:subtotal_tax] = divide_by_quantity_with_rounding(to_f(new_item[:subtotal_tax]), to_f(item[:quantity]))
          new_item[:total_tax] = divide_by_quantity_with_rounding(to_f(new_item[:total_tax]), to_f(item[:quantity]))
          new_item[:subtotal] = (to_f(item[:subtotal]) + to_f(item[:subtotal_tax])) / to_f(item[:quantity])
          new_item[:total] = (to_f(item[:total]) + to_f(item[:total_tax])) / to_f(item[:quantity])

          array << new_item
        end
        array
      end
    end

    def if_needed_to_f(value)
      value.is_a?(Numeric) ? value : value.to_f
    end

    alias :to_f :if_needed_to_f

    def default_fabric_status(item:)
      item = item.decorate
      item.fabric_state = item.fabric&.stock? ? 'available' : 'unavailable_no_ordered'
    end

    private

    def to_cents(price:)
      (price.to_f * 100).round(0)
    end

    def divide_by_quantity_with_rounding(value, quantity)
      (value.to_f / quantity).round(0)
    end

    def to_status(status:)
      Order::STATUSES[status]
    end

    def resolve_category(params:)
      return GIFT_CARD_CATEGORY if has_gift_category?(params['categories'])

      params['categories']&.each do |api_category|
        Product::CATEGORIES.each do |product_category|
          if api_category.downcase.include?(product_category.split(PRODUCT_CATEGORY_SEPARATOR).last.downcase)
            return product_category
          end
        end
      end
      NON_CUSTOM_CATEGORY
    end

    def has_gift_category?(categories)
      categories&.each do |api_category|
        return true if api_category.downcase.include?(GIFT_WORD)
      end
      false
    end

    def resolve_first_name(params:)
      return params['first_name'] unless params['first_name'].blank?
      return params['billing_address']['first_name'] unless params['billing_address']['first_name'].blank?
      params['shipping_address']['first_name']
    end

    def resolve_last_name(params:)
      return params['last_name'] unless params['last_name'].blank?
      return params['billing_address']['last_name'] unless params['billing_address']['last_name'].blank?
      params['shipping_address']['last_name']
    end

    def find_fabric_code(meta:)
      fabric_hash = meta&.detect { |meta_hash| meta_hash['key'].include? FABRIC_CODE_KEY }
      return unless fabric_hash

      if fabric_hash['value'] == FABRIC_CODE_OTHER_VALUE
        meta.each { |meta_hash| return meta_hash['value'] if meta_hash['key'] == FABRIC_CODE_OTHER_KEY }
        nil
      else
        fabric_hash['value'].split(FABRIC_CODE_SEPARATOR).first
      end
    end

    def find_sales_location(name)
      return unless name.present?

      SalesLocation.look_by_name(name)&.id
    end

    def find_sales_person(name)
      return unless name.present?

      splitted_name = name.split(' ')
      first_name = splitted_name[0]
      last_name = splitted_name[1]

      User.look_by_fullname(first_name, last_name)&.id
    end

    def resolve_meta(meta)
      return [] if meta.blank?

      fabric_code_meta = meta.detect do |meta|
        next if meta.nil?

        meta['key'] == FABRIC_CODE_KEY
      end

      return meta unless fabric_code_meta.present?

      meta.delete_if do |meta|
        next if meta.nil?

        meta['key'] == FABRIC_CODE_KEY
      end

      if fabric_code_meta.dig('value')
        meta << {
          'key'   => GRAVITY_FABRIC_CODE_KEY,
          'value' => fabric_code_meta.dig('value'),
          'label' => GRAVITY_FABRIC_CODE_KEY
        }

        meta << {
          'key'   => FABRIC_CODE_KEY,
          'value' => FabricInfo.find_by(fabric_code: fabric_code_meta.dig('value'))&.manufacturer_fabric_code,
          'label' => FABRIC_CODE_KEY
        }
      end

      meta
    end
  end
end
