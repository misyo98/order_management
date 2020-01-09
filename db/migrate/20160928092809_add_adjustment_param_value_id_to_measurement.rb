class AddAdjustmentParamValueIdToMeasurement < ActiveRecord::Migration
  def change
    add_column :measurements, :adjustment_value_id, :integer, after: :adjustment
  end
end
