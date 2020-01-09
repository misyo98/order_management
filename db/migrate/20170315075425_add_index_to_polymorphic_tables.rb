class AddIndexToPolymorphicTables < ActiveRecord::Migration
  def change
    add_index :billings,  [ :billable_type, :billable_id]
    add_index :shippings, [ :shippable_type, :shippable_id]
  end
end
