require 'rails_helper'

RSpec.describe Profiles::DeleteAlteration do
  let(:customer) { create :customer }
  let(:profile) { create :profile }
  let(:category) { create :category }
  let(:param) { create :param }
  let(:category_param) { create :category_param, category: category, param: param }
  let(:profile_category) { create :profile_category, profile: profile, category: category }
  let(:measurement) { create :measurement, profile: profile, final_garment: 10, post_alter_garment: 12, category_param: category_param }
  let(:summary) { create :alteration_summary, profile_id: profile.id }
  let(:alteration) { create :alteration, measurement_id: measurement.id, alteration_summary_id: summary.id, value: 2 }
  let(:info) { create :alteration_info, profile_id: profile.id, category_id: category.id, alteration_summary_id: summary.id }


  context 'with reverting alteration values' do
    let(:delete_with_revert) { true }

    subject(:delete_alteration) { described_class.(summary, delete_with_revert) }

    it 'deletes an alteration' do
      expect(profile.alteration_summaries).to contain_exactly summary
      expect(summary.alterations).to contain_exactly alteration
      expect(summary.alteration_infos).to contain_exactly info

      delete_alteration

      [profile.reload, measurement.reload].each(&:reload)

      expect(measurement.post_alter_garment).to eq 10
      expect(summary.persisted?).to be false
      expect(profile.alteration_summaries.any?).to be false
      expect(profile.alteration_infos.any?).to be false
    end
  end

  context 'without reverting alteration values' do
    let(:delete_with_revert) { nil }

    subject(:delete_alteration) { described_class.(summary, delete_with_revert) }

    it 'deletes an alteration' do
      expect(profile.alteration_summaries).to contain_exactly summary
      expect(summary.alterations).to contain_exactly alteration
      expect(summary.alteration_infos).to contain_exactly info

      delete_alteration

      [profile.reload, measurement.reload].each(&:reload)

      expect(measurement.post_alter_garment).to eq 12
      expect(summary.persisted?).to be false
      expect(profile.alteration_summaries.any?).to be false
      expect(profile.alteration_infos.any?).to be false
    end
  end
end
