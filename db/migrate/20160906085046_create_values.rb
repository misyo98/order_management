class CreateValues < ActiveRecord::Migration
  def change
    create_table :values do |t|
      t.string :title

      t.timestamps null: false
    end
  end
end
