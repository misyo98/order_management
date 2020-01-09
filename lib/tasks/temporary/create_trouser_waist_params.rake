desc 'Only to be used once to create params for Trouser waist body measurement'
task create_trouser_waist_params: :environment do
  already_created = Param.find_by(title: 'Trouser waist')

  if already_created
    puts 'Trouser Waist body measurement already exists.'.red
  else
    param = Param.create(title: 'Trouser waist', input_type: 'values', alias: 'Trouser waist', parameterized_name: 'trouser_waist')
    category_param = CategoryParam.create(category_id: Category.find_by(name: 'Body shape & postures').id, param_id: param.id, order: 103)

    ['Regular', 'High', 'Low'].each do |value|
      category_param.values.create(value_id: Value.find_by(title: value).id)
    end

    default_category_param = CategoryParam.joins(:param).find_by(Param.arel_table[:title].eq('Trouser Waist'))
    default_category_param_value = default_category_param.values.detect { |param_value| param_value.value.title == 'Regular' }

    Profile.with_category('Body shape & postures').find_each(batch_size: 50) do |profile|
      was_adjusted = profile.measurements.where(Measurement.arel_table[:adjustment_value_id].not_eq(nil)).any?

      profile.measurements.create(
        category_param_id: default_category_param.id,
        category_param_value_id: default_category_param_value.id,
        value: 0.0,
        allowance: 0.0,
        adjustment: 0.0,
        adjustment_value_id: was_adjusted ? default_category_param_value.id : nil,
        final_garment: 0.0,
        post_alter_garment: 0.0
      )

      print '.'.yellow
    end

    puts
    puts 'Successfully created Trouser waist params!'.green
  end
end
