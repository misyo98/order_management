# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AlterationTailorDecorator, type: :decorator do
  describe '#currency' do
    let(:tailor) { create :alteration_tailor }
    let(:user) { create :user, country: 'GB', alteration_tailor: tailor }

    subject { described_class.decorate(tailor).formatted_currency }

    it 'returns currency for tailor' do
      expect(subject).to eq 'GBP'
    end
  end
end
