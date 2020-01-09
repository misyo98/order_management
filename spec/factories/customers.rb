FactoryBot.define do
  factory :customer do
    first_name { "MyString" }
    last_name { "MyString" }
    sequence(:email) { |n| "bububu#{n}@gmail.com" }

    after(:build) do |customer|
      customer.class.skip_callback(:create, :before, :check_acquisition_channel)
    end
  end
end
