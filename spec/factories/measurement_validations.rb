FactoryBot.define do
  factory :measurement_validation do
    category_param { nil }
    left_operand { 'value' }
    comparison_operator { '>=' }
    original_expression { '({{jacket.neck.value}} + {{jacket.neck.allowance}}) - 5' }
    calculation_expression { '({{3->value}} + {{2->allowance}}) - 5' }
    original_and_condition { "{{body_shape_postures.square_back_neck.body}} == 'no'" }
    and_condition { "{{4->body}} == 'no'" }
    error_message { "Can't be bigger than {{expression_result}} + 1" }
    comment { 'Explanation comment' }
    fits { [] }
  end
end
