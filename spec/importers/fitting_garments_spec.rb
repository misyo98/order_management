# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Importers::Objects::FittingGarments do
  describe '.call' do
    let!(:shirt_category) { create :category, name: 'Shirt' }
    let!(:jacket_category) { create :category, name: 'Jacket' }
    let!(:neck_param) { create :param, title: 'Neck', input_type: 'digits', parameterized_name: 'neck' }
    let!(:chest_param) { create :param, title: 'Chest', input_type: 'digits', parameterized_name: 'chest' }
    let!(:shirt_neck_category_param) { create :category_param, category: shirt_category, param: neck_param }
    let!(:shirt_chest_category_param) { create :category_param, category: shirt_category, param: chest_param }
    let!(:jacket_neck_category_param) { create :category_param, category: jacket_category, param: neck_param }
    let!(:jacket_chest_category_param) { create :category_param, category: jacket_category, param: chest_param }
    let!(:fitting_garment1) { create :fitting_garment, order: 1, name: '32 - City', category: shirt_category, country: 'GB' }

    let!(:shirt_neck_fitting_measurement) do
      create :fitting_garment_measurement, fitting_garment: fitting_garment1,
        category_param: shirt_neck_category_param, value: 12
    end
    let!(:shirt_chest_fitting_measurement) do
      create :fitting_garment_measurement, fitting_garment: fitting_garment1,
        category_param: shirt_chest_category_param, value: 32
    end

    let(:csv_file) { fixture_file_upload('/fitting_garments.csv', 'fitting_garments/csv') }

    subject { described_class.new(tempfile_path: csv_file.path).call }

    it 'imports fitting garments' do
      expect(fitting_garment1.order).to eq 1
      expect(fitting_garment1.fitting_garment_measurements.first.value).to eq 12
      expect(FittingGarment.find_by(name: '34 - Village')).to be nil

      subject

      fitting_garment1.reload

      fitting_garment2 = FittingGarment.find_by(name: '34 - Village')

      expect(fitting_garment1.order).to eq 3
      expect(fitting_garment1.fitting_garment_measurements.first.value).to eq 14

      expect(fitting_garment2.order).to eq 2
      expect(fitting_garment2.name).to eq '34 - Village'
      expect(fitting_garment2.category).to eq jacket_category
      expect(fitting_garment2.country).to eq 'SG'
      expect(fitting_garment2.fitting_garment_measurements.count).to eq 2
      expect(fitting_garment2.fitting_garment_measurements.first.value).to eq 16
      expect(fitting_garment2.fitting_garment_measurements.second.value).to eq 34
    end
  end
end
