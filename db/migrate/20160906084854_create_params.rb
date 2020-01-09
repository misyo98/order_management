class CreateParams < ActiveRecord::Migration
  def change
    create_table :params do |t|
      t.string :title
      t.integer :type

      t.timestamps null: false
    end
  end
end
