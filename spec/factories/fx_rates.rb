FactoryBot.define do
  factory :fx_rate do
    usd_gbp { "9.99" }
    usd_sgd { "9.99" }
    usd_eur { "9.99" }
    valid_from { "2017-02-16" }
  end
end
