class CreateFittingGarments < ActiveRecord::Migration
  def change
    create_table :fitting_garments do |t|
      t.references :category, index: true, foreign_key: { on_delete: :cascade }
      t.string :name
      t.integer :order

      t.timestamps null: false
    end
  end
end
