context.instance_eval  do
  panel "Measurements" do
    category_params.each do |category_id, params_array|
      div class: 'attributes_table' do
        table class: "measurements_index_table measurement-table-#{category_id} table-bordered" do
          tr do
            profile.show_headers.each do |header|
              th header.titleize
            end
          end
          params_array.each do |category_param|
            measurement = profile.measurements.find { |measurement| measurement.category_param_id == category_param.id }
            if measurement
              render 'admin/customer/measurement', context: self, measurement: measurement, infos: infos, profile: profile, category_id: category_id
            else
              render 'admin/customer/empty_measurement', context: self, category_param: category_param
            end
          end
          render 'admin/customer/additional_info', context: self, infos: infos, profile: profile, category_id: category_id, decorated_comments: decorated_comments
        end
      end
    end
  end
end
