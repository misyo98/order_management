# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MeasurementChecks::Fetcher do
  let(:category_param) { create(:category_param) }
  let(:category_param2) { create(:category_param) }
  let(:category_param3) { create(:category_param) }
  let(:check) { create(:measurement_check, category_param: category_param) }
  let!(:check2) { create(:measurement_check, category_param: category_param2, min: 0.98, max: 0.99) }
  let!(:check3) { create(:measurement_check, category_param: category_param3, calculations_type: :abs_value) }
  let!(:check_cluster) { create(:measurement_check_height_cluster, measurement_check: check, upper_limit: 50, min: 0.1, max: 0.2) }
  let!(:check_cluster2) { create(:measurement_check_height_cluster, measurement_check: check, upper_limit: 60) }
  let(:expected_result) do
    {
      category_param.id => { min: 0.1, max: 0.2 },
      category_param2.id => { min: 0.98, max: 0.99 }
    }
  end

  subject { described_class.fetch(52) }

  it { is_expected.to eq expected_result }
end
