# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MeasurementValidations::Updater do
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
  let!(:measurement_validation) { create :measurement_validation, category_param_id: category_param_neck.id, left_operand: '{{value}}' }
  let(:params) { { left_operand: '10', last_updated_by_id: user.id } }
  let(:user) { create :user }

  subject { described_class.update(measurement_validation, params) }

  context 'valid' do
    it 'updates object' do
      subject

      measurement_validation.reload

      expect(measurement_validation.left_operand).to eq '10'
      expect(measurement_validation.last_updated_by_id).to eq user.id
    end
  end

  context 'invalid' do
    context 'object validations failed' do
      let(:params) do
        {
          category_param_id: nil,
          left_operand: '',
          comparison_operator: '',
          original_expression: '',
          original_and_condition: '',
          error_message: '',
          comment: ''
        }
      end

      it 'does not update the object' do
        validation = subject

        expect(validation.errors.full_messages).to include "Category param can't be blank"
        expect(validation.errors.full_messages).to include "Left operand can't be blank"
        expect(validation.errors.full_messages).to include "Comparison operator can't be blank"
        expect(validation.errors.full_messages).to include "Original expression can't be blank"
        expect(validation.errors.full_messages).to include "Error message can't be blank"
      end
    end

    context 'custom validations failed' do
      let(:params) do
        {
          category_param_id: category_param_neck.id,
          left_operand: '{{value}}',
          comparison_operator: '>=',
          original_expression: '({{jacket.chest.value}} + {{jacket.neck.value}}) - 5',
          original_and_condition: "{{pants.square_back_neck.body}} == 'yes'",
          error_message: "Can't be smaller than {{expression_result}}",
          comment: 'This is a comment'
        }
      end

      it 'does not update the object' do
        validation = subject

        expect(validation.errors.full_messages).to include "Invalid pattern: {{pants.square_back_neck.body}}"
      end
    end
  end
end
