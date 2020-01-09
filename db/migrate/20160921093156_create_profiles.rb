class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.integer :customer_id
      t.boolean :submited, default: 0
      t.integer :author_id

      t.timestamps null: false
    end
  end
end
