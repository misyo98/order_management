class AddDeletedAtToAlterationServices < ActiveRecord::Migration
  def change
    add_column :alteration_services, :deleted_at, :datetime
    add_index :alteration_services, :deleted_at
  end
end
