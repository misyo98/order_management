require 'rails_helper'

RSpec.describe AlterationSummaries::CRUD do
  describe 'alteration update' do
    let!(:customer) { create :customer }
    let!(:profile) { create :profile, customer: customer }
    let!(:user) { create :user }
    let!(:category) { create :category }
    let!(:param) { create :param }
    let!(:category_param) { create :category_param, category: category, param: param }
    let!(:profile_category) { create :profile_category, profile: profile, category: category }
    let!(:measurement) { create :measurement, profile: profile, final_garment: 1, category_param: category_param }
    let!(:summary) { create :alteration_summary, profile_id: profile.id }

    let(:params) do
      ActionController::Parameters.new({
        urgent: true,
        requested_completion: '2019-03-26',
        alteration_request_taken: '2019-03-30',
        delivery_method: 'courier',
        non_altered_items: 'all_altered',
        remaining_items: 'trigger_after_alteration',
        alteration_images: {
          image: [
            uploading_image_file
          ]
        }
      })
    end

    subject(:update_alteration) { described_class.new(params: params).update(summary: summary) }

    context 'update with images' do
      it 'updates summary with images' do
        expect(profile.alteration_summaries).to contain_exactly summary
        expect(summary.images.any?).to be false

        update_alteration

        profile.reload
        summary.reload

        expect(summary.images.any?).to be true
        expect(summary.urgent).to be true
        expect(summary.requested_completion).to eq Date.new(2019, 03, 26)
        expect(summary.alteration_request_taken).to eq Date.new(2019, 03, 30)
      end
    end

    context 'update without images' do
      let(:params) do
        ActionController::Parameters.new({
          urgent: true,
          requested_completion: '2019-03-27',
          alteration_request_taken: '2019-03-31',
          delivery_method: 'courier',
          non_altered_items: 'all_altered',
          remaining_items: 'trigger_after_alteration',
          alteration_images: nil
        })
      end

      it 'updates summary without images' do
        expect(profile.alteration_summaries).to contain_exactly summary
        expect(summary.images.any?).to be false

        update_alteration

        profile.reload
        summary.reload

        expect(summary.images.any?).to be false
        expect(summary.urgent).to be true
        expect(summary.requested_completion).to eq Date.new(2019, 03, 27)
        expect(summary.alteration_request_taken).to eq Date.new(2019, 03, 31)
      end
    end
  end
end
