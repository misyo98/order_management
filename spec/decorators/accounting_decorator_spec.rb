# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountingDecorator, type: :decorator do
  describe '#vat_rate' do
    let!(:vat_rate1) { create :vat_rate, shipping_country: 'SG', rate: 0.07, valid_from: "Sep 1 2018" }
    let!(:vat_rate2) { create :vat_rate, shipping_country: 'SG', rate: 0.0, valid_from: "May 1 2017" }
    let!(:vat_rate3) { create :vat_rate, shipping_country: 'GB', rate: 0.2, valid_from: "Sep 1 2016" }
    let(:shipping_gb) { create :shipping, country: 'GB' }
    let(:shipping_sg) { create :shipping, country: 'SG' }
    let(:order_gb) { create :order, shipping: shipping_gb }
    let(:order_sg) { create :order, shipping: shipping_sg }
    let(:item_gb) { create :line_item, order: order_gb }
    let(:item_sg) { create :line_item, order: order_sg }


    context 'gb item' do
      subject { described_class.decorate(item_gb).vat_rate }

      it 'checks gb vat' do
        expect(subject).to eq(0.2.to_d)
      end
    end

    context 'sg item' do
      subject { described_class.decorate(item_sg).vat_rate }

      it 'checks sg vat' do
        expect(subject).to eq(0.07.to_d)
      end
    end
  end
end
