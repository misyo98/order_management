# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProfileCategory, type: :model do
  describe '#second_to_last_event' do
    let(:customer) { create :customer }
    let(:profile) { create :profile, customer: customer }
    let(:shirt_category) { create :category }
    let(:profile_category) { create :profile_category, profile: profile }
    let!(:category_history) { create :profile_category_history, profile_category: profile_category, status: 'to_be_checked' }
    let!(:category_history2) { create :profile_category_history, profile_category: profile_category, status: 'to_be_fixed' }
    let!(:category_history3) { create :profile_category_history, profile_category: profile_category, status: 'to_be_fixed' }
    let!(:category_history4) { create :profile_category_history, profile_category: profile_category, status: 'to_be_fixed' }

    subject(:second_to_last_event!) { profile_category.history_events.second_to_last_event_status }

    it 'returns to_be_checked state' do
      expect(second_to_last_event!).to eq 'to_be_checked'
    end
  end
end
