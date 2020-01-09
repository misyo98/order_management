FactoryBot.define do
  factory :invoice_file do
    invoice { nil }
    attachment { 'Attachment' }
  end
end
