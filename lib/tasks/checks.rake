namespace :checks do
  task initialize_values: :environment do
    ids = MeasurementCheck.all.pluck(:category_param_id)
    response = Measurements::CheckUpdater.new(ids: ids).update
    puts response
  end

  task nullify: :environment do
    MeasurementCheck.update_all(min: 0, max: 0)
  end

  task initialize_async: :environment do
    ids = MeasurementCheck.all.pluck(:category_param_id)
    UpdateChecks.perform_async(ids)
  end
end
