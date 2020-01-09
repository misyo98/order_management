FactoryBot.define do
  factory :fabric_manager do
    manufacturer_fabric_code { "MyString" }
    fabric_brand_id { nil }
    fabric_book_id { nil }
    status { 'discontinued' }
    estimated_restock_date { nil }
  end
end
