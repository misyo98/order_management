context.instance_eval  do
  tr do
    td measurement.category_field
    td class: 'measurement-td' do
      measurement.param_field
    end
    td measurement.measurement_field
    td measurement.allowance_field
    td measurement.adjustment_field
    td measurement.final_garment_field

    measurement.alterations.each do |alteration|
      td alteration.value_field
    end
    measurement.blank_alterations(infos_count: infos[category_id]&.count, profile: profile)&.times do
      td
    end

    td measurement.post_alter_garment_field if infos[category_id].present?

  end
end
