class RemoveAlterationCountFromProfile < ActiveRecord::Migration
  def change
    remove_column :profiles, :alterations_count
  end
end
