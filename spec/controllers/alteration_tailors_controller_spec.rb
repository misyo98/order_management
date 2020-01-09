# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AlterationTailorsController, type: :controller do
  describe 'POST #create' do
    let(:user) { create :user, role: 1 }
    before(:each) { sign_in user }

    context 'alteration tailor create' do
      it 'creates new alteration tailor' do
        expect {
          post :create, alteration_tailor: { currency: 'gbp' }
        }.to change(AlterationTailor, :count).by 1

        expect(AlterationTailor.last.currency).to eq 'gbp'
      end

      it 'rejects blank currency for alteration tailor' do
        expect {
          post :create, alteration_tailor: { currency: '' }
        }.to change(AlterationTailor, :count).by 0
      end

      it 'rejects invalid currency and raises exception' do
        expect {
          post :create, alteration_tailor:  { currency: 'invalid currency' }
        }.to raise_error(ArgumentError)
      end
    end
  end

  describe 'PATCH #update' do
    let(:sg_tailor) { create :alteration_tailor, currency: 'sgd' }
    let(:gb_tailor) { create :alteration_tailor, currency: 'gbp' }
    let(:user) { create :user, role: 1 }
    before(:each) { sign_in user }

    context 'alteration tailor update' do
      it 'updates currency of the tailor' do
        patch :update, id: sg_tailor, alteration_tailor: { currency: 'gbp' }

        sg_tailor.reload

        expect(sg_tailor.currency).to eq 'gbp'
      end

      it 'keeps actual currency' do
        patch :update, id: gb_tailor, alteration_tailor: { currency: '' }

        gb_tailor.reload

        expect(gb_tailor.currency).to eq 'gbp'
      end

      it 'rejects invalid currency and raises exception' do
        expect {
          patch :update, id: gb_tailor, alteration_tailor: { currency: 'some string' }
        }.to raise_error(ArgumentError)

        expect(gb_tailor.currency).to eq 'gbp'
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:tailor) { create :alteration_tailor, currency: 'sgd' }
    let!(:service) { create :alteration_service }
    let!(:service_tailor) { create :alteration_service_tailor, alteration_service: service, alteration_tailor: tailor }
    let!(:invoice) { create :invoice, alteration_tailor: tailor }
    let!(:summary) { create :alteration_summary, alteration_tailors: [tailor] }
    let!(:summary_line_item) { create :alteration_summary_line_item, alteration_summary: summary, alteration_tailor: tailor }
    let(:user) { create :user, role: 1 }
    before(:each) { sign_in user }

    it 'removes alteration tailor and nullify it for associated objects' do
      expect(AlterationTailor.count).to eq 1
      expect(tailor.alteration_services.count).to eq 1
      expect(service_tailor.alteration_tailor_id).to eq tailor.id
      expect(invoice.alteration_tailor_id).to eq tailor.id
      expect(summary.alteration_tailors).to match_array([tailor])

      delete :destroy, id: tailor.id

      [service_tailor, invoice, summary, summary_line_item].each(&:reload)

      expect(AlterationTailor.count).to eq 0
      expect(service_tailor.alteration_tailor).to be_nil
      expect(invoice.alteration_tailor).to be_nil
      expect(summary.alteration_tailors).to be_empty
      expect(summary_line_item.alteration_tailor).to be_nil
    end
  end
end
