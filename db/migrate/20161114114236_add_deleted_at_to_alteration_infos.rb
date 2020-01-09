class AddDeletedAtToAlterationInfos < ActiveRecord::Migration
  def change
    add_column :alteration_infos, :deleted_at, :datetime
    add_index :alteration_infos, :deleted_at
  end
end
