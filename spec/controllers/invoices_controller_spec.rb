# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvoicesController, type: :controller do
  let(:tailor) { create :alteration_tailor }
  let(:user) { create :user, alteration_tailor: tailor }
  let(:summary) { create :alteration_summary, state: 'to_be_invoiced' }
  let(:summary2) { create :alteration_summary, state: 'invoiced' }
  let(:summary_ids) { [summary.id] }
  let(:invoice_params) { { payment_date: Date.today, alteration_summary_ids: summary_ids } }

  before { sign_in user }

  describe 'POST #create' do
    it 'creates' do
      expect { post :create, invoice: invoice_params, format: :js }
        .to change { Invoice.count }.by 1

      invoice = Invoice.last

      summary.reload
      expect(invoice.alteration_summary_ids).to contain_exactly summary.id
      expect(invoice.payment_date).to eq Date.today
      expect(summary.state).to eq 'invoiced'
    end
  end

  describe 'PATCH #add_summary' do
    let!(:invoice) { create :invoice }

    it 'assigns summary' do
      patch :add_summary, id: invoice.id, alteration_summary_id: summary.id, format: :js

      invoice.reload
      summary.reload

      expect(invoice.alteration_summary_ids).to contain_exactly summary.id
      expect(summary.state).to eq 'invoiced'
    end
  end

  describe 'PATCH #update' do
    let!(:invoice) { create :invoice }

    it 'updates' do
      patch :update, id: invoice.id, invoice: invoice_params.merge(payment_date: Date.yesterday, alteration_summary_ids: [summary2.id]), format: :js

      invoice.reload
      summary2.reload

      expect(invoice.payment_date).to eq Date.yesterday
      expect(summary2.state).to eq 'paid'
    end
  end

  describe 'DELETE #remove_summary' do
    let!(:invoice) { create :invoice, payment_date: Date.today, alteration_summary_ids: [summary2.id] }

    it 'removes summary' do
      expect(invoice.alteration_summary_ids).to contain_exactly summary2.id
      expect(summary2.state).to eq 'invoiced'

      delete :remove_summary, id: invoice.id, alteration_summary_id: summary2.id, format: :js

      invoice.reload
      summary2.reload

      expect(invoice.alteration_summary_ids).to be_empty
      expect(summary2.state).to eq 'to_be_invoiced'
    end
  end

  describe 'DELETE #destroy' do
    let!(:invoice) { create :invoice, payment_date: Date.today, alteration_summary_ids: [summary2.id] }
    let!(:invoice_file) { create :invoice_file, invoice: invoice }

    it 'removes invoice and attached file' do
      expect(Invoice.count).to eq 1
      expect(InvoiceFile.count).to eq 1
      expect(invoice.invoice_file).to be invoice_file

      delete :destroy, id: invoice.id

      expect(Invoice.count).to eq 0
      expect(InvoiceFile.count).to eq 0
    end
  end
end
