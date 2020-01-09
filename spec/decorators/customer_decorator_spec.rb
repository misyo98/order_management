# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CustomerDecorator, type: :decorator do
  describe '#category_status' do
    let(:customer) { create :customer }
    let(:profile) { create :profile, customer: customer }
    let(:shirt_category) { create :category, name: 'Shirt' }
    let(:pants_category) { create :category, name: 'Pants' }
    let(:jacket_category) { create :category, name: 'Jackets' }
    let!(:shirt_profile_category) { create :profile_category, profile: profile, category: shirt_category, status: 'submitted' }
    let!(:jacket_profile_category) { create :profile_category, profile: profile, category: jacket_category }
    let(:category_name) { 'Shirt' }
    let(:categories) { [shirt_category, pants_category, jacket_category] }
    let(:n_a_result) { { status: 'n/a', class: 'label label-default' } }
    let(:decorated_object) { customer.decorate }

    context 'without profile' do
      let(:profile) { nil }

      subject { decorated_object.shirt_status }

      it { is_expected.to eq n_a_result }
    end

    context 'when prfoile does not have corresponding category' do
      let(:category_name) { 'Jacket' }

      subject { decorated_object.jacket_status }

      it { is_expected.to eq n_a_result }
    end

    context 'when profile category exists' do
      let(:submitted_status_result) { { status: 'submitted', class: 'label label-success' } }

      subject { decorated_object.shirt_status }

      it { is_expected.to eq submitted_status_result }
    end
  end
end
