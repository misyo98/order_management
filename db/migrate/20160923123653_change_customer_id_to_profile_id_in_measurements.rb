class ChangeCustomerIdToProfileIdInMeasurements < ActiveRecord::Migration
  def change
    rename_column :measurements, :customer_id, :profile_id
  end
end
