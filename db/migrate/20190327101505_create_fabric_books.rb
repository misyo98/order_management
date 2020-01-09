class CreateFabricBooks < ActiveRecord::Migration
  def change
    create_table :fabric_books do |t|
      t.string :title

      t.timestamps null: false
    end
  end
end
