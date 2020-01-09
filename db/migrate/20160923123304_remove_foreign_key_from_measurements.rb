class RemoveForeignKeyFromMeasurements < ActiveRecord::Migration
  def change
    remove_foreign_key :measurements, :customer
  end
end
