# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AlterationServicesController, type: :controller do
  describe 'PATCH #update' do
    let(:category) { create :category }
    let(:service) { create :alteration_service, category_id: category.id, name: 'test', order: 100}
    let(:service_tailor) { create :alteration_service_tailor, alteration_tailor_id: tailor.id, alteration_service: service, price: 2 }
    let(:tailor) { create :alteration_tailor }
    let(:user) { create :user, role: 1 }

    before(:each) { sign_in user }

    it 'updates service with nil price' do
      patch :update, id: service, alteration_service: { name: 'Test service',
        alteration_service_tailors_attributes: {
            '0': {
              id: service_tailor.id, price: nil
            }
          }
        }
      service.reload
      service_tailor.reload
      expect(service.name).to eq 'Test service'
      expect(service_tailor.price).to eq nil
    end
  end
end
