namespace :dropdown_alteration_values do
  update_alteration_values = ->(measurement) do
    return unless measurement
    measurement_value_id = measurement.adjustment_value_id ? measurement.adjustment_value_id : measurement.category_param_value_id
    measurement.alterations.where(category_param_value_id: nil).update_all(category_param_value_id: measurement_value_id)
  end

  task update: :environment do
    ActiveRecord::Base.transaction do
      begin
        back_shape_param = CategoryParam.joins(:param, :category).find_by('params.title' => 'Back Shape', 'categories.name' => 'Body shape & postures')
        hem_param = CategoryParam.joins(:param, :category).find_by('params.title' => 'Hem', 'categories.name' => 'Body shape & postures')
        armhole_param = CategoryParam.joins(:param, :category).find_by('params.title' => 'Armhole', 'categories.name' => 'Body shape & postures')

        Profile.find_each do |profile|
          profile_back_shape = profile.find_measurement(back_shape_param.id)
          profile_hem = profile.find_measurement(hem_param.id)
          profile_armhole = profile.find_measurement(armhole_param.id)

          update_alteration_values.call(profile_back_shape)
          update_alteration_values.call(profile_hem)
          update_alteration_values.call(profile_armhole)
        end
      rescue => error
        puts error
        raise ActiveRecord::Rollback
      end
    end
  end
end
