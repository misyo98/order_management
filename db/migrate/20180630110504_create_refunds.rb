class CreateRefunds < ActiveRecord::Migration
  def change
    create_table :refunds do |t|
      t.references :line_item, index: true, foreign_key: true
      t.decimal :amount, precision: 8, scale: 2
      t.string :reason
      t.string :comment

      t.timestamps null: false
    end
  end
end
