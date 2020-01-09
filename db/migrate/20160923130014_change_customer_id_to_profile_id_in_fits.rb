class ChangeCustomerIdToProfileIdInFits < ActiveRecord::Migration
  def change
    rename_column :profile_images, :customer_id, :profile_id
  end
end
