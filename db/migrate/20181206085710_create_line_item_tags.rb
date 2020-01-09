class CreateLineItemTags < ActiveRecord::Migration
  def change
    create_table :line_item_tags do |t|
      t.belongs_to :tag, index: true, foreign_key: true
      t.belongs_to :line_item, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
