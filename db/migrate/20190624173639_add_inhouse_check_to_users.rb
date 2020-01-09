class AddInhouseCheckToUsers < ActiveRecord::Migration
  def change
    add_column :users, :inhouse, :boolean
  end
end
