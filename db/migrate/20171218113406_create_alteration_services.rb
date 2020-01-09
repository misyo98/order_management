class CreateAlterationServices < ActiveRecord::Migration
  def change
    create_table :alteration_services do |t|
      t.integer :category_id
      t.string :name
      t.integer :order
      t.timestamps null: false
    end
  end
end
