FactoryBot.define do
  factory :measurement_issue do
    issueable { nil }
    issue_subject { nil }
    fixed { false }
  end
end
