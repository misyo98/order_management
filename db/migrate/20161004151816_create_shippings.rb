class CreateShippings < ActiveRecord::Migration
  def change
    create_table :shippings do |t|
      t.integer :customer_id
      t.string :first_name
      t.string :last_name
      t.string :company
      t.string :address_1
      t.string :address_2
      t.string :city
      t.string :state
      t.string :postcode
      t.string :country

      t.timestamps null: false
    end
  end
end
