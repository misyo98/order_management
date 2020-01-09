class AddDeletedAtToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :deleted_at, :datetime
    add_index :profiles, :deleted_at
  end
end
