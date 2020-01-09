# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TriggerDeliveryArranged do
  let(:customer) { create :customer }
  let(:order) { create :order, customer: customer }
  let(:line_item) { create :line_item, state: 'delivery_email_sent', order: order }
  let(:line_item2) { create :line_item, state: 'new', order: order }
  let(:line_items) { [line_item, line_item2] }

  describe '.call' do
    context 'with day' do
      subject { described_class.(line_items, Date.today.to_s) }

      it 'changes the state correctly' do
        subject

        expect(line_item.state).to eq 'delivery_arranged'
        expect(line_item.delivery_appointment_date).to eq Date.today
      end

      it 'does not change the state for item in a wrong initial state' do
        subject

        expect(line_item2.state).to eq 'new'
        expect(line_item2.delivery_appointment_date).to be_nil
      end
    end
    context 'without day' do
      subject { described_class.(line_items) }

      it 'changes the state correctly' do
        subject

        expect(line_item.state).to eq 'delivery_arranged'
        expect(line_item.delivery_appointment_date).to be_nil
      end

      it 'does not change the state for item in a wrong initial state' do
        subject

        expect(line_item2.state).to eq 'new'
        expect(line_item2.delivery_appointment_date).to be_nil
      end
    end
  end
end
