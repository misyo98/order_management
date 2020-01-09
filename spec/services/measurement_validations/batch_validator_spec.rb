# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MeasurementValidations::BatchValidator do
  let(:category_jacket) { create :category, name: 'Jacket', parameterized_name: 'jacket' }
  let(:category_body) { create :category, name: 'Body shapes & postures', parameterized_name: 'body_shape_postures' }
  let(:param_neck) { create :param, title: 'Neck', parameterized_name: 'neck' }
  let(:param_chest) { create :param, title: 'Chest', parameterized_name: 'chest' }
  let(:param_square_back) { create :param, title: 'Square Back Neck?', parameterized_name: 'square_back_neck' }
  let(:value) { create :value, title: 'Yes', parameterized_name: 'yes' }
  let!(:category_param_neck) { create :category_param, category: category_jacket, param: param_neck }
  let!(:category_param_chest) { create :category_param, category: category_jacket, param: param_chest }
  let!(:category_param_square) { create :category_param, category: category_body, param: param_square_back }
  let!(:category_param_value) { create :category_param_value, category_param: category_param_square, value: value }
  let!(:measurement_validation) do
    create :measurement_validation,
      category_param_id: category_param_neck.id,
      left_operand: '{{value}}',
      comparison_operator: '<=',
      original_expression: '({{jacket.chest.value}} + {{jacket.neck.value}}) - 5',
      calculation_expression: "({{#{category_param_chest.id}->value}} + {{#{category_param_neck.id}->value}}) - 5",
      original_and_condition: "{{body_shape_postures.square_back_neck.body}} == 'yes'",
      and_condition: "{{#{category_param_square.id}->body}} == 'yes'",
      error_message: "Can't be smaller than {{expression_result}}",
      comment: 'This is a comment'
  end
  let!(:measurement_validation2) do
    create :measurement_validation,
      category_param_id: category_param_chest.id,
      left_operand: '{{value}}',
      comparison_operator: '<=',
      original_expression: '22',
      calculation_expression: '22',
      original_and_condition: '',
      and_condition: '',
      error_message: "Can't be smaller than {{expression_result}}"
  end
  let!(:validation_param) do
    create :validation_parameter,
      measurement_validation: measurement_validation,
      name: 'difference',
      original_expression: "{{body_shape_postures.square_back_neck.body}} == 'yes' ? 1.75 : 1",
      calculation_expression: "{{#{category_param_square.id}->body}} == 'yes' ? 1.75 : 1"
  end
  let(:params) do
    {
      "#{category_param_square.id}" => {
        "category_param_value_id" => "#{category_param_value.id}",
              "category_param_id" => "#{category_param_square.id}"
      },
      "#{category_param_neck.id}" => {
                            "value" => "31.0",
                        "allowance" => "-1.0",
                    "final_garment" => "30.0",
                "category_param_id" => "#{category_param_neck.id}",
          "category_param_value_id" => ""
      },
      "#{category_param_chest.id}" => {
                            "value" => "16.5",
                        "allowance" => "-0.75",
                    "final_garment" => "15.75",
                "category_param_id" => "#{category_param_chest.id}",
          "category_param_value_id" => ""
      }
    }
  end
  let(:fit_params) do
    {
      "3" => {
              "checked" => "0",
                  "fit" => "singapore_slim",
          "category_id" => "666"
      },
      "4" => {
              "checked" => "0",
                  "fit" => "regular",
          "category_id" => "#{category_jacket.id}"
      },
      "5" => {
              "checked" => "0",
                  "fit" => "self_slim",
          "category_id" => "#{category_body.id}"
      }
    }
  end

  subject do
    described_class.validate(
      params: params,
      category_params: [category_param_neck, category_param_chest],
      fit_params: fit_params
    )
  end

  it 'assigns errors' do
    result = subject

    expect(result.errors).to eq({
      category_param_neck.id => ["Can't be smaller than 42.5"],
      category_param_chest.id => ["Can't be smaller than 22"]
    })
  end
end
