# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Exporters::Objects::FittingGarments do
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
    let!(:fitting_garment2) { create :fitting_garment, order: 2, name: '34.5 - Village', category: jacket_category, country: 'SG' }

    let!(:shirt_neck_fitting_measurement) do
      create :fitting_garment_measurement, fitting_garment: fitting_garment1,
        category_param: shirt_neck_category_param, value: 12
    end
    let!(:shirt_chest_fitting_measurement) do
      create :fitting_garment_measurement, fitting_garment: fitting_garment1,
        category_param: shirt_chest_category_param, value: 32
    end

    let!(:jacket_neck_fitting_measurement) do
      create :fitting_garment_measurement, fitting_garment: fitting_garment2,
        category_param: jacket_neck_category_param, value: 14
    end
    let!(:jacket_chest_fitting_measurement) do
      create :fitting_garment_measurement, fitting_garment: fitting_garment2,
        category_param: jacket_chest_category_param, value: 34.5
    end

    subject { described_class.new.call }

    it 'builds a measurements csv file with formatted data' do
      expect([Category.count, CategoryParam.count, Param.count, FittingGarment.count, FittingGarmentMeasurement.count]).
        to eq ([2, 4, 2, 2, 4])

      temp_file    = TmpFileManager.save_data_as_csv(subject, 'fitting_garments')
      data_array   = CSV.readlines(temp_file.attachment.file.path)
      headers      = data_array.first
      values_row_1 = data_array.second
      values_row_2 = data_array.third

      expect(headers).to contain_exactly(
        'Order', 'Name', 'Category', 'Country', 'SHIRT, Neck', 'SHIRT, Chest', 'JACKET, Neck', 'JACKET, Chest'
      )

      expect(values_row_1).to contain_exactly(
        "#{fitting_garment1.order}", "#{fitting_garment1.name}", "#{fitting_garment1.category.name}", "#{fitting_garment1.country}",
        "#{shirt_neck_fitting_measurement.value}", "#{shirt_chest_fitting_measurement.value}", nil, nil
      )

      expect(values_row_2).to contain_exactly(
        "#{fitting_garment2.order}", "#{fitting_garment2.name}", "#{fitting_garment2.category.name}", "#{fitting_garment2.country}",
        nil, nil, "#{jacket_neck_fitting_measurement.value}", "#{jacket_chest_fitting_measurement.value}"
      )
    end
  end
end
