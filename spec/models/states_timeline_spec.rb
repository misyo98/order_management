# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatesTimeline, type: :model do
  describe '#allowed_time_for_country' do
    let(:timeline) { create(:states_timeline, allowed_time_uk: 3, allowed_time_sg: 5) }


    context 'for Singapore currency' do
      subject { timeline.allowed_time_for_country('SGD') }

      it 'is expected to return correct allowed time' do
        expect(subject).to eq 5
      end
    end

    context 'for other currency' do
      let(:currencies) { %w(GBP USD UAH) }

      subject { timeline.allowed_time_for_country(currencies.sample) }

      it 'is expected to return correct allowed time' do
        expect(subject).to eq 3
      end
    end

    context 'without allowed time set' do
      let(:currencies) { %w(GBP USD UAH SGD) }
      let(:no_allowed_time_timeline) { create(:states_timeline, allowed_time_uk: nil, allowed_time_sg: nil) }

      subject { no_allowed_time_timeline.allowed_time_for_country(currencies.sample) }

      it { is_expected.to eq 1 }
    end
  end

  describe '#resolve_allowed_time' do
    let(:sales_location) { create(:sales_location) }
    let(:sales_location2) { create(:sales_location) }
    let(:timeline) { create(:states_timeline, allowed_time_uk: 3, allowed_time_sg: 5) }
    let!(:sales_location_timeline) do
      create :sales_location_timeline, sales_location: sales_location, states_timeline: timeline, allowed_time: 7
    end

    subject { timeline.resolve_allowed_time(sales_location.id, 'SGD') }

    it { is_expected.to eq 7 }

    context 'when sales_location timeline does not exist' do
      subject { timeline.resolve_allowed_time(sales_location2.id, 'SGD') }

      it { is_expected.to eq 5 }
    end
  end
end
