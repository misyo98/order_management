# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AlterationService, type: :model do
  describe '#destroy' do
    let(:service1) { create :alteration_service, name: 'service' }
    let(:service2) { create :alteration_service, name: 'service1' }
    let(:tailor) { create :alteration_tailor }
    let!(:tailor_service1) { create :alteration_service_tailor,
                                alteration_service: service1,
                                alteration_tailor: tailor,
                                price: 10 }
    let!(:tailor_service2) { create :alteration_service_tailor,
                                alteration_service: service2,
                                alteration_tailor: tailor,
                                price: 20 }
    let(:item) { create :line_item, alteration_tailor_id: tailor.id }
    let(:summary) { create :alteration_summary, amount: 30 }
    let!(:summary_items) { create :alteration_summary_line_item,
                            line_item: item,
                            alteration_summary: summary }
    let!(:summary_services1) { create :alteration_summary_service,
                                alteration_summary: summary,
                                alteration_service: service1 }
    let!(:summary_services2) { create :alteration_summary_service,
                                alteration_summary: summary,
                                alteration_service: service2 }

    it 'destroys all summary services' do
      summary_services1.destroy
      summary.reload
      expect(summary.alteration_summary_services).to contain_exactly summary_services2
      expect(summary.amount).to eq 30
    end
  end

  describe 'existing_service_with_price' do
    let!(:tailor) { create :alteration_tailor }
    let!(:tailor1) { create :alteration_tailor }
    let!(:user) { create :user, role: 'tailor', alteration_tailor_id: tailor.id }
    let!(:service) { create :alteration_service, name: 'Initial', author: user }
    let!(:valid_service) { create :alteration_service, name: 'Valid', author: user }
    let!(:initial_tailor_service) { create :alteration_service_tailor,
                                alteration_service: service,
                                alteration_tailor_id: tailor.id,
                                price: 10 }
    let!(:invalid_tailor_service) { build :alteration_service_tailor,
                                alteration_service: service,
                                alteration_tailor_id: tailor.id,
                                price: 20 }
    let!(:valid_tailor_service) { build :alteration_service_tailor,
                                alteration_service: valid_service,
                                alteration_tailor_id: tailor1.id,
                                price: 30 }

    it 'is not valid service because it is already exists' do
      expect(service.valid?).not_to be true
      expect(service.errors).not_to be_empty
      expect(service.errors.messages[:service_exists].first).to include 'if you need to change the cost'
    end

    it 'is valid service' do
      expect(valid_service.valid?).to be true
      expect(valid_service.errors).to be_empty
    end
  end
end
