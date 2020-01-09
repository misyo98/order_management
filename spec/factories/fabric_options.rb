FactoryBot.define do
  factory :fabric_option do
    fabric_tab { nil }
    title { "MyString" }
    order { 1 }
    button_type { 1 }
    placeholder { "MyString" }
    outfitter_selection { 1 }
    tuxedo { 1 }
    premium { 1 }
    fusible { 1 }
    manufacturer { 1 }
    price { nil }
  end
end
