# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Exporters::Objects::Measurements do
  describe '.call' do
    before do
      allow(Thread).to receive(:new).and_yield.and_return(Class.new { def join; end }.new)
    end

    let!(:customer) { create :customer, first_name: 'Karl', last_name: 'Franz' }
    let!(:profile) { create :profile, customer: customer }
    let(:profiles) { Profile.all }

    let!(:body_comment) do
      create :admin_comment, body: 'Ripped like Arnold or something.', resource: customer, resource_type: 'Customer',
             category: body_category, submission: false
    end

    let!(:height_comment) do
      create :admin_comment, body: 'Really tall one here.', resource: customer, resource_type: 'Customer',
             category: height_category, submission: true
    end

    let!(:body_category) { create :category, name: 'Body shape & postures' }
    let!(:body_profile_category) { create :profile_category, category: body_category, profile: profile, status: :confirmed }
    let!(:body_fit) { create :fit, fit: :slim, category: body_category, profile: profile }
    let!(:body_type_param) { create :param, title: 'Body Type', input_type: 'values', parameterized_name: 'body_type' }
    let!(:body_type_category_param) { create :category_param, category: body_category, param: body_type_param }
    let!(:body_type_value) { create :value, title: 'Muscular', parameterized_name: 'muscular' }
    let!(:body_type_alter_value) { create :value, title: 'Very Muscular', parameterized_name: 'very_muscular' }
    let!(:body_type_category_param_value) { create :category_param_value, value: body_type_value }
    let!(:body_type_category_param_alter_value) { create :category_param_value, value: body_type_alter_value }

    let!(:body_type_measurement) do
      create :measurement, category_param: body_type_category_param, category_param_value: body_type_category_param_value,
      adjustment_value: body_type_category_param_alter_value, profile: profile
    end

    let!(:height_category) { create :category, name: 'Height' }
    let!(:height_profile_category) { create :profile_category, category: height_category, profile: profile, status: :submitted }
    let!(:height_fit) { create :fit, fit: :slim, category: height_category, profile: profile }
    let!(:height_inches_param) { create :param, title: 'Height (inches)', input_type: 'digits', parameterized_name: 'height_inches' }
    let!(:height_inches_category_param) { create :category_param, category: height_category, param: height_inches_param }

    let!(:height_measurement) do
      create :measurement, value: 96, allowance: 3, final_garment: 99, post_alter_garment: 100,
             category_param: height_inches_category_param, profile: profile
    end

    let!(:height_alteration) { create :alteration, measurement: height_measurement, value: 1 }

    subject { described_class.new(profiles: profiles).call }

    it 'builds a measurements csv file with formatted data' do
      expect([Profile.count, Category.count, CategoryParam.count, CategoryParamValue.count, Param.count, Value.count, Measurement.count]).
        to eq ([1, 2, 2, 2, 2, 2, 2])

      temp_file = TmpFileManager.save_data_as_csv(subject, 'measurements')
      structured_data_array = CSV.readlines(temp_file.attachment.file.path)
      headers = structured_data_array.first
      row = structured_data_array.second

      expect(headers).to contain_exactly(
        'Customer ID', 'Customer Name', 'Body shape & postures Fit', 'Body shape & postures Status', 'Body shape & postures Comment',
        'Body shape & postures Body Type - Body', 'Body shape & postures Body Type - Final', 'Height Fit', 'Height Status',
        'Height Comment', 'Height Height (inches) - Body', 'Height Height (inches) - Allowance', 'Height Height (inches) - Final'
      )

      expect(row).to contain_exactly(
        "#{customer.id}", "#{customer.full_name}", "#{body_fit.fit}", "#{body_profile_category.status}", "#{body_comment.body}",
        "#{body_type_measurement.category_param_value.value_title}", "#{body_type_measurement.adjustment_value.value_title}",
        "#{height_fit.fit}", "#{height_profile_category.status}", "#{height_comment.body}",
        "#{height_measurement.value}", "#{height_measurement.allowance}", "#{height_measurement.post_alter_garment}"
      )
    end
  end
end
