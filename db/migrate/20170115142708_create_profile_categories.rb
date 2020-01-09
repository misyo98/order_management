class CreateProfileCategories < ActiveRecord::Migration
  def change
    create_table :profile_categories do |t|
      t.integer :profile_id
      t.integer :category_id
      t.integer :status, default: 0

      t.timestamps null: false
    end
  end
end
