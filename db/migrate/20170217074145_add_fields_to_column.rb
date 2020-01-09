class AddFieldsToColumn < ActiveRecord::Migration
  def change
    add_column :columns, :label, :string, after: :with_collection
    add_column :columns, :sorting_scope, :string, after: :label
  end
end
