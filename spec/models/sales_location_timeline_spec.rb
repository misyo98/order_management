# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SalesLocationTimeline, type: :model do
  describe '.for_location' do
    let(:sales_location) { create(:sales_location) }
    let(:sales_location2) { create(:sales_location) }
    let(:timeline) { create :states_timeline, allowed_time_uk: 3, allowed_time_sg: 5 }
    let!(:location_timeline1) { create :sales_location_timeline, sales_location: sales_location, states_timeline: timeline }
    let!(:location_timeline2) { create :sales_location_timeline, sales_location: sales_location2, states_timeline: timeline }

    subject { timeline.sales_location_timelines.for_location(sales_location.id) }

    it { is_expected.to eq location_timeline1 }
  end
end
