module LineItems
  module Helper
    extend self

    def form_alteration_params(item_ids:)
      return { category_names: [], pes_number: nil } unless item_ids
      
      items = LineItem.where(id: item_ids)
      { category_names: items.first.local_category, pes_numbers: items.map(&:m_order_number),
        line_item_ids: item_ids, sales_locations: items.map(&:sales_location_name) }
    end
  end
end
