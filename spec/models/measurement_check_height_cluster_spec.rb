# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MeasurementCheckHeightCluster, type: :model do
  describe '.closest_by_height' do
    let!(:check_cluster1) { create(:measurement_check_height_cluster, upper_limit: 55) }
    let!(:check_cluster3) { create(:measurement_check_height_cluster, upper_limit: 70) }
    let(:height) { 70 }

    subject { described_class.closest_by_height(height).first }

    it { is_expected.to eq check_cluster3 }

    context 'when actual value is missing' do
      let(:height) { 59 }

      it 'takes closest value' do
        expect(subject).to eq check_cluster1
      end
    end
  end
end
