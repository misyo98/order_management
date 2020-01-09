class AddDeletedAtToAlterationServiceTailors < ActiveRecord::Migration
  def change
    add_column :alteration_service_tailors, :deleted_at, :datetime
    add_index :alteration_service_tailors, :deleted_at
  end
end
