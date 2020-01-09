class AddWeightAndAgeToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :weight, :decimal, precision: 5, scale: 2
    add_column :customers, :weight_unit, :string
    add_column :customers, :age, :integer
  end
end
