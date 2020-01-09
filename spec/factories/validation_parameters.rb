FactoryBot.define do
  factory :validation_parameter do
    measurement_validation { nil }
    name { 'difference' }
    original_expression { "{{body_shape_posture.square_back_neck.body}} == 'full_figure' ? 1.75 : 1" }
    calculation_expression { "{{4->body}} == 'full_figure' ? 1.75 : 1" }
  end
end
