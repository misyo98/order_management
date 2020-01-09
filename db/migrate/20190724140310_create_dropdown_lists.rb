class CreateDropdownLists < ActiveRecord::Migration
  def change
    create_table :dropdown_lists do |t|
      t.string :title

      t.timestamps null: false
    end
  end
end
