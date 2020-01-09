FactoryBot.define do
  factory :alteration_info do
    profile
    category
    manufacturer_code { "MyString" }
    comment { "MyText" }
    alteration_summary
  end
end
