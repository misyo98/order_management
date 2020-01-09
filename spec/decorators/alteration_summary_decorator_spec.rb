# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AlterationSummaryDecorator, type: :decorator do
  let(:summary) { create :alteration_summary }
  let(:alteration_service) { create :alteration_service, name: 'My Service' }
  let(:alteration_tailor) { create :alteration_tailor, currency: :sgd }
  let(:line_item) { create :line_item }
  let!(:alteration_summary_line_item) { create :alteration_summary_line_item, line_item: line_item, alteration_summary: summary, alteration_tailor: alteration_tailor }
  let!(:alteration_summary_service) { create :alteration_summary_service, alteration_summary: summary, alteration_service: alteration_service }
  let(:decorated_object) { described_class.decorate(summary) }

  describe '#currency' do
    subject { decorated_object.currency }

    it 'returns currency' do
      expect(subject).to eq 'SGD'
    end
  end

  describe '#alteration_service_names' do
    subject { decorated_object.alteration_service_names }

    it 'returns service names' do
      expect(subject).to eq 'My Service'
    end
  end

  describe '#add_service_link_title' do
    subject { decorated_object.add_service_link_title }

    context 'link title for summary in to_be_updated state' do
      let(:summary) { create :alteration_summary, state: 'to_be_updated' }

      it 'returns link_title' do
        expect(subject).to eq 'Add services'
      end
    end

    context 'link title for summary in to_be_invoiced state' do
      let(:summary) { create :alteration_summary, state: 'to_be_invoiced' }

      it 'returns link_title' do
        expect(subject).to eq 'Edit services'
      end
    end
  end

  describe '#maybe_amount_link' do
    subject { decorated_object.maybe_amount_link }

    context 'link for summary amount' do
      let(:summary) { create :alteration_summary, amount: 0, alteration_services: [], service_updated_at: DateTime.now }

      it 'returns link_title' do
        expect(subject).to eq '0.0 SGD'
      end
    end

    context 'link for summary amount' do
      let(:summary) { create :alteration_summary, amount: 5 }

      it 'returns link_title' do
        expect(subject).to match '<a class=\"alteration-service-list\" data-remote=\"true\" href=\"/alteration_summaries'
      end
    end
  end

  describe '#sales_person' do
    let!(:sales_person) { create :user, first_name: 'John', last_name: 'Doe' }
    let!(:item) { create :line_item, sales_person_id: sales_person.id }
    let!(:summary) { create :alteration_summary, line_item_ids: [item.id] }
    let!(:summary_item) { create :alteration_summary_line_item, alteration_summary_id: summary.id, line_item_id: item.id}

    subject { decorated_object.sales_person }

    it 'returns full name of a sales person' do
      expect(subject).to eq 'John Doe'
    end
  end

  describe '#maybe_payment_required_label' do
    subject { decorated_object.maybe_payment_required_label }

    context 'payment required' do
      let(:summary) { create :alteration_summary, payment_required: true }

      it 'returns yes for payment_required' do
        expect(subject).to eq 'PAYMENT REQUIRED'
      end
    end

    context 'payment is not required' do
      let(:summary) { create :alteration_summary }

      it 'returns nothing' do
        expect(subject).to be_nil
      end
    end
  end
end
