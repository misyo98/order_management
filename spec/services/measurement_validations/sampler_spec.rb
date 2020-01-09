# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MeasurementValidations::Sampler do
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

  subject { described_class.try_sample(validation_params, measurement_params, category_param_neck) }

  context 'when validation params are incomplete' do
    let(:validation_params) do
      {
        category_param_id: nil,
        left_operand: '',
        comparison_operator: '>=',
        original_expression: '({{jacket.chest.value}} + {{jacket.neck.value}}) - 5',
        original_and_condition: "{{body_shape_postures.square_back_neck.body}} == 'yes'",
        error_message: "Can't be smaller than {{expression_result}}",
        comment: 'This is a comment'
      }
    end
    let(:measurement_params) { {} }

    it 'returns object errors' do
      errors = subject

      expect(errors[:validation_result_errors]).to be_empty
      expect(errors[:object]).to include "Category param can't be blank"
      expect(errors[:object]).to include "Left operand can't be blank"
    end
  end

  context 'when validation params are broken' do
    let(:validation_params) do
      {
        category_param_id: category_param_neck.id,
        left_operand: '{{value}}',
        comparison_operator: '>=',
        original_expression: '({{pants.chest.value}} + {{pants.neck.value}}) - 5',
        original_and_condition: "{{body_shape_postures.square_back_neck.body}} == 'yes'",
        error_message: "Can't be smaller than {{expression_result}}",
        comment: 'This is a comment'
      }
    end
    let(:measurement_params) { {} }

    it 'returns object errors' do
      errors = subject

      expect(errors[:validation_result_errors]).to be_empty
      expect(errors[:object]).to include 'Invalid pattern: {{pants.chest.value}}'
      expect(errors[:object]).to include 'Invalid pattern: {{pants.neck.value}}'
    end
  end

  context 'when measurements params are broken' do
    let(:validation_params) do
      {
        category_param_id: category_param_neck.id,
        left_operand: '{{value}}',
        comparison_operator: '>=',
        original_expression: '({{jacket.chest.value}} + {{jacket.neck.value}}) - 5',
        original_and_condition: "{{body_shape_postures.square_back_neck.body}} == 'yes'",
        error_message: "Can't be smaller than {{expression_result}}",
        comment: 'This is a comment'
      }
    end
    let(:measurement_params) { {} }

    it 'returns object errors' do
      errors = subject

      expect(errors[:validation_result_errors]).to be_empty
      expect(errors[:object]).to include "undefined method `[]' for nil:NilClass"
    end
  end

  context 'when validation is correct and matching' do
    let(:validation_params) do
      {
        category_param_id: category_param_neck.id,
        left_operand: '{{value}}',
        comparison_operator: '<=',
        original_expression: '({{jacket.chest.value}} + {{jacket.neck.value}}) - 5',
        calculation_expression: "({{#{category_param_chest.id}->value}} + {{#{category_param_neck.id}->value}}) - 5",
        original_and_condition: "{{body_shape_postures.square_back_neck.body}} == 'yes'",
        and_condition: "{{#{category_param_square.id}->body}} == 'yes'",
        error_message: "Can't be smaller than {{expression_result}}",
        comment: 'This is a comment'
      }
    end
    let(:measurement_params) do
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

    it 'returns validation_result_errors' do
      errors = subject

      expect(errors[:object]).to be_empty
      expect(errors[:validation_result_errors]).to contain_exactly "Can't be smaller than 42.5"
    end
  end
end
