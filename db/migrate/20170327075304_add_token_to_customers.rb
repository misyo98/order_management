class AddTokenToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :token, :string, after: :last_contact_date

    Customer.find_each do |c|
      c.update_attribute(:token, SecureRandom.uuid.gsub(/\-/,''))
    end
  end
end
