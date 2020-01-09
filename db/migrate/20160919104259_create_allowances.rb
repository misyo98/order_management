class CreateAllowances < ActiveRecord::Migration
  def change
    create_table :allowances do |t|
      t.integer :category_param_id
      t.decimal :slim, precision: 8, scale: 2, default: 0
      t.decimal :singapore_slim, precision: 8, scale: 2, default: 0
      t.decimal :regular, precision: 8, scale: 2, default: 0
      t.decimal :classic, precision: 8, scale: 2, default: 0

      t.timestamps null: false
    end
  end
end
