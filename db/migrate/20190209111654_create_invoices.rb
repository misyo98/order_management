class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.references :alteration_tailor, index: true, foreign_key: true
      t.integer :status, default: 0
      t.date :payment_date

      t.timestamps null: false
    end
  end
end
