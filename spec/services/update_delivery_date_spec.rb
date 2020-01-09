# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpdateDeliveryDate do
  let!(:customer) { create :customer }
  let!(:order) { create :order, customer: customer }
  let!(:line_item1) { create :line_item, state: 'delivery_arranged', order: order }
  let!(:line_item2) { create :line_item, state: 'delivery_email_sent', order: order }

  describe '.call' do
    context 'with day' do
      subject { described_class.(customer, Date.today.to_s) }

      it 'changes the date correctly' do
        subject
        line_item1.reload

        expect(line_item1.state).to eq 'delivery_arranged'
        expect(line_item1.delivery_appointment_date).to eq Date.today
      end

      it 'does not changes the date for item in a wrong initial state' do
        subject
        line_item2.reload

        expect(line_item2.state).to eq 'delivery_email_sent'
        expect(line_item2.delivery_appointment_date).to be_nil
      end
    end
    context 'without day' do
      subject { described_class.(customer) }

      it 'does not changes the date for item' do
        subject
        line_item1.reload

        expect(line_item1.state).to eq 'delivery_arranged'
        expect(line_item1.delivery_appointment_date).to be_nil
      end
    end
  end
end
