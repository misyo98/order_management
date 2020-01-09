class CreateCategoryParams < ActiveRecord::Migration
  def change
    create_table :category_params do |t|
      t.references :category, index: true, foreign_key: true
      t.references :param, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
