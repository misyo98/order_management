FactoryBot.define do
  factory :measurement_check do
    category_param_id { nil }
    percentile_id { nil }
    min { 0.0 }
    max { 0.0 }
    percentile_of { :height }
    calculations_type { :percentile }
    min_percentile { 5 }
    max_percentile { 95 }
  end
end
