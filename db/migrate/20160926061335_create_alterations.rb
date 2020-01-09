class CreateAlterations < ActiveRecord::Migration
  def change
    create_table :alterations do |t|
      t.integer :author_id
      t.integer :measurement_id
      t.decimal :measurement, precision: 8, scale: 2, default: 0
      t.integer :category_param_value_id

      t.timestamps null: false
    end
  end
end
