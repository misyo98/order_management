context.instance_eval  do
  panel "", class: 'table_for_copy out-of-space' do
    items_hash = {}
    category_params.each do |category_id, params_array|
      div class: 'attributes_table' do
        table class: "measurements_index_table" do
          params_array.each do |category_param|
            measurement = profile.measurements.detect { |measurement| measurement.category_param_id == category_param.id }
            if measurement
              render 'admin/customer/copy_table/measurement', context: self, measurement: measurement, infos: infos, profile: profile, category_id: category_id
            else
              render 'admin/customer/empty_measurement', context: self, category_param: category_param
            end
          end
          item = customer_items.order(created_at: :desc).find { |item| categories[category_id].in? LineItem::CATEGORY_KEYS[item.product_category] }

          items_hash[categories[category_id]] = item.manufacturer if item
          if categories[category_id] == 'Body shape & postures'
            items_hash.each do |key, value|
              tr do
                td key
                td 'Manufacturer'
                td value
              end
            end
          end
        end
      end
    end
  end
end
