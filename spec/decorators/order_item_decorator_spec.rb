# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrderItemDecorator, type: :decorator do
  describe '#status' do
    let(:sales_location) { create :sales_location }
    let(:customer) { create :customer }
    let(:order) { create :order, customer: customer }
    let(:item) { create :line_item, order: order, state: 'delivery_email_sent', sales_location: sales_location }

    subject { described_class.decorate(item).status }

    it 'generates text and url' do
      expect(subject).to match 'At Office - Please arrange your fitting appointment here'
      expect(subject).to match 'href'
      expect(subject).to match "#{customer.token}"
      expect(subject).to match "#{item.sales_location_delivery_calendar_link}"
    end
  end
end
