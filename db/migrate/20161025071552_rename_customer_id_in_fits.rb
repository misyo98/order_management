class RenameCustomerIdInFits < ActiveRecord::Migration
  def change
    rename_column :fits, :customer_id, :profile_id
  end
end
