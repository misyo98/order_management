class CreateLineItemScopes < ActiveRecord::Migration
  def change
    create_table :line_item_scopes do |t|
      t.string :label
      t.text :states

      t.timestamps null: false
    end
  end
end
