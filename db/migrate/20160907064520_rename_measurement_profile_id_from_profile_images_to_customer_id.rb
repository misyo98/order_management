class RenameMeasurementProfileIdFromProfileImagesToCustomerId < ActiveRecord::Migration
  def change
    rename_column :profile_images, :measurement_profile_id, :customer_id
  end
end
