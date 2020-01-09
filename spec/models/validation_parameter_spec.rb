# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ValidationParameter, type: :model do
  it { is_expected.to belong_to :measurement_validation }
  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :original_expression }
end
