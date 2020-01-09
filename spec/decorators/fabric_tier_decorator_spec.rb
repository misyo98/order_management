# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FabricTierDecorator, type: :decorator do
  describe '#prices_field' do
    let(:fabric_tier) { double title: 'Fabric Tier', fabric_tier_categories: [tier_category, tier_category2] }
    let(:fabric_category) { double title: 'Shirts' }
    let(:fabric_category2) { double title: 'Trousers' }

    context 'fabric_tier with added prices' do
      let(:tier_category) { double fabric_category: fabric_category, decorate: double(price_field: 'GBP: 12, SGD: 11') }
      let(:tier_category2) { double fabric_category: fabric_category2, decorate: double(price_field: 'GBP: 21, SGD: 22') }

      subject { described_class.decorate(fabric_tier).prices_field }

      it 'returns formatted price' do
        expect(subject).to match('<h4><span class=\"label label-success\">Shirts</span>')
        expect(subject).to match('<h4><span class=\"label label-success\">Trousers</span>')
        expect(subject).to match('[Shirts: GBP: 12, SGD: 11], [Pants: GBP: 21, SGD: 22]')
      end
    end
  end

  describe '#fabric_category_label' do
    let!(:fabric_tier) { create :fabric_tier, title: 'Fabric Tier' }
    let!(:fabric_category) { create :fabric_category, title: 'Shirts' }

    context 'fabric_tier_category label' do
      let!(:tier_category) { create :fabric_tier_category, fabric_tier: fabric_tier, fabric_category: fabric_category }

      subject { described_class.decorate(fabric_tier).fabric_category_label(tier_category) }

      it 'returns formatted fabric_category title label' do
        expect(subject).to match('<h4><span class=\"label label-success\">Shirts</span>')
      end
    end
  end
end
