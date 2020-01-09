class CreateProfileCategoryHistories < ActiveRecord::Migration
  def change
    create_table :profile_category_histories do |t|
      t.references :profile_category, index: true, foreign_key: true
      t.string :status
      t.references :author, index: true

      t.timestamps null: false
    end
  end
end
