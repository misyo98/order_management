# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profile, type: :model do
  describe '#alteration_number' do
    let(:profile) { create :profile }
    let(:summary1) { create :alteration_summary }
    let(:summary2) { create :alteration_summary }
    let(:summary3) { create :alteration_summary }
    let!(:info1) { create :alteration_info, profile: profile, alteration_summary: summary1, manufacturer_code: 'PES1' }
    let!(:info11) { create :alteration_info, profile: profile, alteration_summary: summary1, manufacturer_code: 'PES1' }
    let!(:info2) { create :alteration_info, profile: profile, alteration_summary: summary2, manufacturer_code: 'PES1' }
    let!(:info3) { create :alteration_info, profile: profile, alteration_summary: summary3, manufacturer_code: 'PES1, PES2' }
    let!(:info31) { create :alteration_info, profile: profile, alteration_summary: summary2, manufacturer_code: 'PES1, PES2' }
    let!(:info32) { create :alteration_info, profile: profile, alteration_summary: summary1, manufacturer_code: 'PES1, PES2' }

    subject { profile.alteration_number(number) }

    context 'for none numbers' do
      let(:number) { ''.split(', ') }

      it { is_expected.to eq({}) }
    end

    context 'for one number' do
      let(:number) { ['PES1'] }

      it { is_expected.to eq({ 'PES1' => 3 }) }
    end

    context 'for 2 numbers' do
      let(:number) { ['PES1', 'PES2'] }

      it { is_expected.to eq({ 'PES1' => 3, 'PES2' => 3 }) }
    end
  end
end
