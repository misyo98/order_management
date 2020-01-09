task update_customers_token: :environment do
  Customer.where(token: nil).find_each do |customer|
    customer.set_token
    customer.save
  end
end