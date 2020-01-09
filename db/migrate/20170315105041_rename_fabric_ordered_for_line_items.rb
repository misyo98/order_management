class RenameFabricOrderedForLineItems < ActiveRecord::Migration
  def up
    rename_column :line_items, :fabric_ordered, :fabric_ordered_date
    Column.where(name: 'fabric_ordered_date').update_all(name: 'fabric_ordered_date_field')
  end

  def down
    rename_column :line_items, :fabric_ordered_date, :fabric_ordered
    Column.where(name: 'fabric_ordered_date_field').update_all(name: 'fabric_ordered_date')
  end
end
