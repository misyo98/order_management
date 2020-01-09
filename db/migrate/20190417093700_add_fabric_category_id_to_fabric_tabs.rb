class AddFabricCategoryIdToFabricTabs < ActiveRecord::Migration
  def change
    add_reference :fabric_tabs, :fabric_category, after: :id, index: true, foreign_key: { on_delete: :nullify }
  end
end
