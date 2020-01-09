task add_waistcoat_back_length_measurement_check: :environment do
  waistcoat_back_length_measurement =
    MeasurementCheck.find_or_create_by(
      category_param_id: CategoryParam.joins(:param).find_by(Param.arel_table[:title].eq('Waistcoat Back Length')).id,
      percentile_id: CategoryParam.find_param(:height, :height).id
    )

  Measurements::CheckUpdater.new(ids: [waistcoat_back_length_measurement.category_param_id]).update

  puts 'Added Waistcoat Back Length Measurement Check'
end
