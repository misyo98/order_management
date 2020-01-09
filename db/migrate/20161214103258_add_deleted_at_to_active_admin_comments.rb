class AddDeletedAtToActiveAdminComments < ActiveRecord::Migration
  def change
    add_column :active_admin_comments, :deleted_at, :datetime
    add_index :active_admin_comments, :deleted_at
  end
end
