class RenameColumnInColumns < ActiveRecord::Migration
  def change
    Column.where(columnable_type: 'LineItemScope', name: 'first_name').update_all(label: 'First Name')
  end
end
