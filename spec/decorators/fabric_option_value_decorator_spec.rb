# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FabricOptionValueDecorator, type: :decorator do
  describe '#price_field' do
    context 'fabric_option_value with price' do
      let(:option_value) { create :fabric_option_value, title: 'Value', manufacturer: :old_m, price: { 'GBP' => 12, 'SGD' => 11 } }

      subject { described_class.decorate(option_value).price_field }

      it 'returns formatted price' do
        expect(subject).to eq('GBP: 12, SGD: 11')
      end
    end

    context 'fabric_option_value with no price' do
      let(:option_value) { create :fabric_option_value, title: 'Value', manufacturer: :old_m, price: nil }

      subject { described_class.decorate(option_value).price_field }

      it 'returns Empty' do
        expect(subject).to eq('Empty')
      end
    end
  end
end
