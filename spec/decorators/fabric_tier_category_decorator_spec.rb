# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FabricTierCategoryDecorator, type: :decorator do
  let!(:user) { create :user, first_name: 'Admin', last_name: 'User', country: 'GB' }
  let!(:user2) { create :user, first_name: 'Outfitter', last_name: 'User', country: 'SG' }
  let!(:fabric_tier) { create :fabric_tier, title: 'Tier' }
  let!(:fabric_category) { create :fabric_category, title: 'Fabric Category' }
  let!(:tier_category) do
    create :fabric_tier_category, fabric_tier: fabric_tier, fabric_category: fabric_category,
      price: { 'GBP' => 12, 'SGD' => 11 }
  end

  describe '#price_field' do
    context 'fabric_tier_category with price' do
      let(:tier_category) do
        create :fabric_tier_category, fabric_tier: fabric_tier, fabric_category: fabric_category,
          price: { 'GBP' => 12, 'SGD' => 11 }
      end

      subject { described_class.decorate(tier_category).price_field }

      it 'returns formatted price' do
        expect(subject).to eq('GBP: 12, SGD: 11')
      end
    end

    context 'fabric_tier_category with no price' do
      let(:tier_category) { create :fabric_tier_category, fabric_tier: fabric_tier, fabric_category: fabric_category, price: nil }

      subject { described_class.decorate(tier_category).price_field }

      it 'returns Empty' do
        expect(subject).to eq('Empty')
      end
    end
  end

  describe '#country_specific_category_price' do
    subject { described_class.decorate(tier_category).country_specific_category_price }

    context 'GB user' do
      before do
        sign_in user
      end

      it 'returns GB price' do
        expect(subject).to eq "#{tier_category.price['GBP']} GBP"
      end
    end

    context 'SG user' do
      before do
        sign_in user2
      end

      it 'returns SG price' do
        expect(subject).to eq "#{tier_category.price['SGD']} SGD"
      end
    end
  end
end
