class AddDeleteAtToFabricBrandsAndBooks < ActiveRecord::Migration
  def change
    add_column :fabric_brands, :deleted_at, :datetime
    add_column :fabric_books, :deleted_at, :datetime
    add_column :fabric_infos, :deleted_at, :datetime
    add_index :fabric_brands, :deleted_at
    add_index :fabric_books, :deleted_at
    add_index :fabric_infos, :deleted_at
  end
end
