desc 'Only to be used once for copying every pants fitting garments for chinos'
task copy_pants_fitting_garments: :environment do
  puts 'Starting copying'

  chinos_category = Category.find_by(name: 'Chinos')

  FittingGarment.where(category_id: Category.find_by(name: 'Pants')).find_each do |pants_fitting_garment|
    chinos_f_g = pants_fitting_garment.dup
    chinos_f_g.category_id = chinos_category.id

    if chinos_f_g.save
      chinos_measurements =
        pants_fitting_garment.fitting_garment_measurements.each_with_object([]) do |pant_measurement, chinos_measurements|
          chinos_category_param = CategoryParam.find_by(category_id: chinos_category.id, param_id: pant_measurement.category_param.param_id)
          chinos_measurement = pant_measurement.dup
          chinos_measurement.fitting_garment_id = chinos_f_g.id
          chinos_measurement.category_param_id = chinos_category_param.id
          chinos_measurements << chinos_measurement
        end

      FittingGarmentMeasurement.import chinos_measurements
    end

    print '.'
  end
  puts " All done now!"
end
