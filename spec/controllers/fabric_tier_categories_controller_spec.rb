# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FabricTierCategoriesController, type: :controller do
  let(:user) { create :user }
  let(:fabric_category) { create :fabric_category, title: 'Fabric Category' }
  let(:fabric_tier) { create :fabric_tier, title: 'Fabric Tier' }
  let(:fabric_tier_category_params) { { fabric_category_id: fabric_category.id, fabric_tier_id: fabric_tier.id } }
  let(:price_params) { [{ currency: 'SGD', value: '5' }] }

  before { sign_in user }

  describe 'POST #create' do
    it 'creates' do
      expect { post :create, fabric_tier_category: fabric_tier_category_params, price_array: price_params, format: :js }
        .to change { FabricTierCategory.count }.by 1

      fabric_tier_category = FabricTierCategory.last

      expect(fabric_tier_category.fabric_category_id).to eq fabric_category.id
      expect(fabric_tier_category.fabric_tier_id).to eq fabric_tier.id
      expect(fabric_tier_category.price).to eq({ 'SGD' => '5' })
    end
  end

  describe 'PATCH #update' do
    let(:fabric_category) { create :fabric_category, title: 'Fabric Category' }
    let(:fabric_tier) { create :fabric_tier, title: 'Fabric Tier' }
    let(:fabric_tier_category) { create :fabric_tier_category }

    it 'updates' do
      expect(fabric_tier_category.fabric_category_id).to be nil
      expect(fabric_tier_category.fabric_tier_id).to be nil

      patch :update, id: fabric_tier_category.id,
        fabric_tier_category: { fabric_category_id: fabric_category.id, fabric_tier_id: fabric_tier.id },
        price_array: price_params.push({ currency: 'GBP', value: '3' }), format: :js

      fabric_tier_category.reload

      expect(fabric_tier_category.fabric_category_id).to eq fabric_category.id
      expect(fabric_tier_category.fabric_tier_id).to eq fabric_tier.id
      expect(fabric_tier_category.price).to eq({ 'GBP' => '3', 'SGD' => '5' })
    end
  end
end
