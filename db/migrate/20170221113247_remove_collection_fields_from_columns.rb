class RemoveCollectionFieldsFromColumns < ActiveRecord::Migration
  def change
    remove_column :columns, :collection_name
    remove_column :columns, :with_collection
  end
end
