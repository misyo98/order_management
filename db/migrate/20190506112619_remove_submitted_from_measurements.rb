class RemoveSubmittedFromMeasurements < ActiveRecord::Migration
  def change
    remove_column :measurements, :submitted, :boolean
  end
end
