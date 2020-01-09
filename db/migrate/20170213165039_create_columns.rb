class CreateColumns < ActiveRecord::Migration
  def change
    create_table :columns do |t|
      t.string :columnable_type
      t.integer :columnable_id
      t.string :name
      t.integer :order
      t.string :collection_name
      t.boolean :visible, default: 1
      t.boolean :with_collection, default: 0

      t.timestamps null: false
    end
  end
end
