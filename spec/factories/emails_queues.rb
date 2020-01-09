FactoryBot.define do
  factory :emails_queue do
    recipient_id { 1 }
    recipient_type { "MyString" }
    subject_id { 1 }
    subject_type { "MyString" }
    params { "MyText" }
  end
end
