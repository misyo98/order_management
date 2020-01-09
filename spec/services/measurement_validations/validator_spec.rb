# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MeasurementValidations::Validator do
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
      category_param: category_param_neck,
      validations: [measurement_validation],
      fit_params: fit_params
    )
  end

  it 'assigns error' do
    result = subject

    expect(result.errors).to contain_exactly "Can't be smaller than 42.5"
  end

  context 'when validation condition does not match params' do
    before { measurement_validation.update(comparison_operator: '>=') }

    it 'assigns no errors' do
      result = subject

      expect(result.errors).to be_empty
      expect(result.success?).to be true
    end
  end

  context 'when validation rule is broken' do
    before { measurement_validation.update(calculation_expression: 'invalid') }

    it 'assigns execution_errors' do
      expect(measurement_validation.execution_errors).to be_empty

      subject

      expect(measurement_validation.reload.execution_errors).not_to be_empty
    end
  end

  context 'when used in expression param is missing' do
    before do
      measurement_validation.update(
        calculation_expression: "({{-1->value}} + {{#{category_param_neck.id}->value}}) - 5"
      )
    end

    it 'assigns execution_errors' do
      expect(measurement_validation.execution_errors).to be_empty

      subject

      expect(measurement_validation.reload.execution_errors).not_to be_empty
    end
  end

  context 'when extra parameters are being used' do
    before do
      measurement_validation.update(
        calculation_expression: "({{#{category_param_chest.id}->value}} + {{#{category_param_neck.id}->value}}) - {{difference}}"
      )
    end

    it 'assigns error' do
      result = subject

      expect(measurement_validation.execution_errors).to be_empty
      expect(result.errors).to contain_exactly "Can't be smaller than 45.75"
    end
  end

  context 'when validation rule is restricted by fit' do
    before { measurement_validation.update(fits: ['regular']) }

    it 'applies validation rule' do
      result = subject

      expect(measurement_validation.execution_errors).to be_empty
      expect(result.errors).to contain_exactly "Can't be smaller than 42.5"
    end

    context 'when fit does not match' do
      before { measurement_validation.update(fits: ['slim']) }

      it 'skips validation rule' do
        result = subject

        expect(measurement_validation.execution_errors).to be_empty
        expect(result.errors).to be_empty
      end
    end
  end
end
