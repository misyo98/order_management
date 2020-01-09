# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MeasurementValidations::Preprocessor do
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
  let(:validation) { MeasurementValidation.new(params) }

  let(:params) do
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

  subject { described_class.preprocess!(validation) }

  context 'without extra parameters' do
    context 'when left operand is a key' do
      it 'properly replaces values in original expression' do
        subject

        expect(validation.category_param_id).to eq category_param_neck.id
        expect(validation.left_operand).to eq '{{value}}'
        expect(validation.comparison_operator).to eq '>='
        expect(validation.original_expression).to eq '({{jacket.chest.value}} + {{jacket.neck.value}}) - 5'
        expect(validation.calculation_expression).to eq "({{#{category_param_chest.id}->value}} + {{#{category_param_neck.id}->value}}) - 5"
        expect(validation.original_and_condition).to eq "{{body_shape_postures.square_back_neck.body}} == 'yes'"
        expect(validation.and_condition).to eq "{{#{category_param_square.id}->body}} == 'yes'"
        expect(validation.error_message).to eq "Can't be smaller than {{expression_result}}"
        expect(validation.comment).to eq 'This is a comment'
      end
    end
  end

  context 'with extra parameters' do
    let(:params) do
      {
        category_param_id: category_param_neck.id,
        left_operand: '{{value}}',
        comparison_operator: '>=',
        original_expression: '({{jacket.chest.value}} + {{jacket.neck.value}}) - 5 + {{difference}}',
        original_and_condition: "{{body_shape_postures.square_back_neck.body}} == 'yes'",
        error_message: "Can't be smaller than {{expression_result}}",
        comment: 'This is a comment'
      }
    end
    let(:validation_parameters_params) do
      {
        '1' => {
          name: 'difference',
          original_expression: "{{body_shape_postures.square_back_neck.body}} == 'full_figure' ? 1.75 : 1"
        },

        '2' => {
          name: 'const_value',
          original_expression: '7.6'
        }
      }
    end
    let(:validation) { MeasurementValidation.new(params.merge(validation_parameters_attributes: validation_parameters_params)) }

    it 'properly replaces values in original expression' do
      result = subject

      first_param = validation.validation_parameters.first
      second_param = validation.validation_parameters.last

      expect(result.errors).to be_empty

      expect(first_param.name).to eq 'difference'
      expect(first_param.original_expression).to eq "{{body_shape_postures.square_back_neck.body}} == 'full_figure' ? 1.75 : 1"
      expect(first_param.calculation_expression).to eq "{{#{category_param_square.id}->body}} == 'full_figure' ? 1.75 : 1"

      expect(second_param.name).to eq 'const_value'
      expect(second_param.original_expression).to eq '7.6'
      expect(second_param.calculation_expression).to eq '7.6'
    end
  end

  context 'errors' do
    let(:params) do
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

    it 'returns errors if any' do
      result = subject

      expect(result.errors).not_to be_empty
      expect(result.errors).to include 'Invalid pattern: {{pants.chest.value}}'
      expect(result.errors).to include 'Invalid pattern: {{pants.neck.value}}'
    end
  end
end
