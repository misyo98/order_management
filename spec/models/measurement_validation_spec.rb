# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MeasurementValidation, type: :model do
  it { is_expected.to belong_to :category_param }
  it { is_expected.to have_many :validation_parameters }
  it { is_expected.to validate_presence_of :category_param_id }
  it { is_expected.to validate_presence_of :left_operand }
  it { is_expected.to validate_presence_of :comparison_operator }
  it { is_expected.to validate_presence_of :original_expression }
  it { is_expected.to validate_presence_of :error_message }
end
