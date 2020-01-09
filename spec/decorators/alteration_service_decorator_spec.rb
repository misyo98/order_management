# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AlterationServiceDecorator, type: :decorator do
  let(:tailor) { create :alteration_tailor, currency: :sgd }
  let(:service_tailor) { create :alteration_service_tailor, alteration_tailor_id: tailor.id, price: 5 }
  let(:service) { create :alteration_service, name: 'Test Service', alteration_service_tailors: [service_tailor] }
  let(:decorated_object) { described_class.decorate(service) }

  describe '#formatted_name' do
    subject { decorated_object.formatted_name }

    it 'returns name for existing service' do
      expect(subject).to eq 'Test Service'
    end

    it 'returns formatted name for deleted service' do
      service.destroy
      service.reload

      expect(subject).to eq '(DELETED SERVICE) - Test Service'
    end
  end
  
  describe '#formatted_price_field' do
    subject { decorated_object.formatted_price_field(tailor.decorate) }

    it 'returns name for existing service' do
      expect(subject).to eq '5.0 SGD'
    end
  end
end
