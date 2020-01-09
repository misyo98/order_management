class CreatePaymentDetails < ActiveRecord::Migration
  def change
    create_table :payment_details do |t|
      t.integer :order_id
      t.string :method_id
      t.string :method_title
      t.string :paid
      t.string :transaction_id

      t.timestamps null: false
    end
  end
end
