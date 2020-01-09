class AddRoleToUser < ActiveRecord::Migration
  def change
    add_column :users, :role, :integer, after: :last_name, default: 0
  end
end
