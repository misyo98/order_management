class AddCountryToUser < ActiveRecord::Migration
  def change
    add_column :users, :country, :string, after: :role, default: 'GB'
  end
end
