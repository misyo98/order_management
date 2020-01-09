class CreateFits < ActiveRecord::Migration
  def change
    create_table :fits do |t|
      t.integer :category_id
      t.integer :customer_id
      t.integer :fit

      t.timestamps null: false
    end
  end
end
