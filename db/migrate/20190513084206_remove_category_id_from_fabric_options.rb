class RemoveCategoryIdFromFabricOptions < ActiveRecord::Migration
  def up
    remove_reference :fabric_options, :fabric_category, index: true, foreign_key: true
  end
  
  def down
    add_reference :fabric_options, :fabric_category, after: :id, index: true, foreign_key: true
  end
end
