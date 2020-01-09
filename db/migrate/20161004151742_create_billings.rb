class CreateBillings < ActiveRecord::Migration
  def change
    create_table :billings do |t|
      t.integer :customer_id
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :company
      t.string :address_1
      t.string :address_2
      t.string :city
      t.string :state
      t.string :postcode
      t.string :country
      t.string :phone

      t.timestamps null: false
    end
  end
end
