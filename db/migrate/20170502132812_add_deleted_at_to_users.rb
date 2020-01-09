class AddDeletedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :deleted_at, :datetime, after: :updated_at
    add_index :users, :deleted_at
  end
end
