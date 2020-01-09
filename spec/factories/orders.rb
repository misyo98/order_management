FactoryBot.define do
  factory :order do
    number { "MyString" }
    customer
    currency { 'GBP' }
    status { :completed }
    
    after(:build) do |order|
      order.class.skip_callback(:create, :before, :check_if_first_order)
    end
  end
end
