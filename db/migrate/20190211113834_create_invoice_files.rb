class CreateInvoiceFiles < ActiveRecord::Migration
  def change
    create_table :invoice_files do |t|
      t.references :invoice, index: true, foreign_key: true
      t.string :attachment

      t.timestamps null: false
    end
  end
end
