# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CancelDelivery do
  let!(:line_item) { create :line_item, state: 'delivery_arranged', delivery_appointment_date: Date.today }
  let!(:line_item2) { create :line_item, state: 'delivery_arranged', delivery_appointment_date: Date.today }

  describe '.call' do
    subject { described_class.(LineItem.all) }

    it 'changes the state correctly' do
      expect { subject }.to change { Sidekiq::Worker.jobs.size }.by 0

      line_item.reload
      line_item2.reload

      expect(line_item.state).to eq 'delivery_email_sent'
      expect(line_item.delivery_appointment_date).to be_nil
      expect(line_item2.state).to eq 'delivery_email_sent'
      expect(line_item2.delivery_appointment_date).to be_nil
    end
  end
end
