class CreateShirtShoulderMeasurementCheck < ActiveRecord::Migration
  def up
    shirt_shoulder_measurement =
      MeasurementCheck.find_or_create_by(
        category_param_id: CategoryParam.joins(:param).find_by(Param.arel_table[:title].eq('Shoulder')).id,
        percentile_id: CategoryParam.find_param(:height, :height).id
      )

    Measurements::CheckUpdater.new(ids: [shirt_shoulder_measurement.category_param_id]).update
  end

  def down
    MeasurementCheck.find_by(
      category_param_id: CategoryParam.joins(:param).find_by(Param.arel_table[:title].eq('Shoulder')).id
    )&.destroy
  end
end
