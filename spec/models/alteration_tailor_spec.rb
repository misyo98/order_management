# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AlterationTailor, type: :model do
  describe 'alteration tailor' do
    let(:tailor) { create :alteration_tailor, currency: 'sgd' }

    it 'checks sg tailor for sgd currency' do
      expect(tailor.sgd?).to be true
    end

    it 'checks sg tailor for gbp currency' do
      expect(tailor.gbp?).to be false
    end

    it 'returns formatted currency' do
      expect(tailor.decorate.formatted_currency).to eq 'SGD'
    end
  end
end
