FactoryBot.define do
  factory :user do
    sequence(:first_name) { |i| "Ivan-#{i}" }
    sequence(:last_name) { |i| "Petrenko-#{i}" }
    sequence(:email) { |i| "ivan@mail#{i}.com" }
    password { '123456' }
    password_confirmation { '123456' }
  end
end
