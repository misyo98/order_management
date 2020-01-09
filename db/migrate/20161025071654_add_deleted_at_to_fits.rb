class AddDeletedAtToFits < ActiveRecord::Migration
  def change
    add_column :fits, :deleted_at, :datetime
    add_index :fits, :deleted_at
  end
end
