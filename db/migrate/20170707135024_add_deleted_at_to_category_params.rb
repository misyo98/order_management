class AddDeletedAtToCategoryParams < ActiveRecord::Migration
  def change
    add_column :category_params, :deleted_at, :datetime
    add_index :category_params, :deleted_at
  end
end
