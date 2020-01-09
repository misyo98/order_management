task default_value_for_hem_and_back_shape: :environment do
  ActiveRecord::Base.transaction do
    begin
      back_shape_param = CategoryParam.joins(:param, :category).find_by('params.title' => 'Back Shape', 'categories.name' => 'Body shape & postures')
      hem_param = CategoryParam.joins(:param, :category).find_by('params.title' => 'Hem', 'categories.name' => 'Body shape & postures')
      arched_back_param = CategoryParam.joins(:param, :category).find_by('params.title' => 'Arched back', 'categories.name' => 'Body shape & postures')
      armhole_param = CategoryParam.joins(:param, :category).find_by('params.title' => 'Armhole', 'categories.name' => 'Body shape & postures')
      straight_hem_value = CategoryParamValue.find_by(category_param: CategoryParam.joins(:param, :category).find_by('params.title' => 'Hem', 'categories.name' => 'Body shape & postures'), value_id: Value.find_by(title: 'Straight').id)
      normal_back_value = CategoryParamValue.find_by(category_param: CategoryParam.joins(:param, :category).find_by('params.title' => 'Back Shape', 'categories.name' => 'Body shape & postures'), value_id: Value.find_by(title: 'Normal').id)
      concaive_back_value = CategoryParamValue.find_by(category_param: CategoryParam.joins(:param, :category).find_by('params.title' => 'Back Shape', 'categories.name' => 'Body shape & postures'), value_id: Value.find_by(title: 'Slightly Concave Waist').id)
      armhole_regular_value = CategoryParamValue.find_by(category_param: CategoryParam.joins(:param, :category).find_by('params.title' => 'Armhole', 'categories.name' => 'Body shape & postures'), value_id: Value.find_by(title: 'Regular').id)

      Profile.find_each do |profile|
        profile_arched_back = profile.find_measurement(arched_back_param.id)
        next unless profile_arched_back

        arched_back_value = profile_arched_back.adjustment_value&.value_title || profile_arched_back.value_title
        back_shape_params =
          case arched_back_value
          when 'No'
            { category_param: back_shape_param, category_param_value_id: normal_back_value.id, adjustment_value_id: normal_back_value.id }
          when 'Yes'
            { category_param: back_shape_param, category_param_value_id: concaive_back_value.id, adjustment_value_id: concaive_back_value.id }
          end

        profile_back_shape = profile.measurements.create!(back_shape_params) unless profile.find_measurement(back_shape_param.id)
        profile_hem = profile.measurements.create!(category_param: hem_param, category_param_value_id: straight_hem_value.id, adjustment_value_id: straight_hem_value.id) unless profile.find_measurement(hem_param.id)
        profile_armhole = profile.measurements.create!(category_param: armhole_param, category_param_value_id: armhole_regular_value.id, adjustment_value_id: armhole_regular_value.id) unless profile.find_measurement(armhole_param.id)

        profile_arched_back.alterations.each do |alteration|
          profile_back_shape.alterations.create!(alteration_summary_id: alteration.alteration_summary_id, author_id: alteration.author_id) if profile_back_shape
          profile_hem.alterations.create!(alteration_summary_id: alteration.alteration_summary_id, author_id: alteration.author_id) if profile_hem
          profile_armhole.alterations.create!(alteration_summary_id: alteration.alteration_summary_id, author_id: alteration.author_id) if profile_armhole
        end
      end
    rescue => error
      puts error
      raise ActiveRecord::Rollback
    end
  end
end
