FactoryBot.define do
  factory :sales_location do
    name { "MyString" }
    showroom_address { 'Bla street' }
    delivery_calendar_link { 'http://localhost:3000/hello' }
  end
end
