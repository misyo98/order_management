# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FabricTiersController, type: :controller do
  let(:user) { create :user }
  let(:fabric_category) { create :fabric_category, title: 'Fabric Category' }
  let(:fabric_tier_params) { { title: 'Fabric Tier', order: 1,
    fabric_tier_categories_attributes: {
      '1' => {
          fabric_category_id: fabric_category.id,
          price: {
            'SGD' => '5'
          }
        }
      }
    }
  }

  before { sign_in user }

  describe 'POST #create' do
    it 'creates' do
      expect { post :create, fabric_tier: fabric_tier_params, format: :js }
        .to change { FabricTier.count }.by 1

      fabric_tier = FabricTier.last

      expect(fabric_tier.title).to eq 'Fabric Tier'
      expect(fabric_tier.order).to eq 1
      expect(fabric_tier.fabric_tier_categories.count).to eq 1
    end
  end

  describe 'PATCH #update' do
    before(:each) do
      request.env["HTTP_REFERER"] = "editing fabric_tier_page"
    end
    let(:fabric_tier) { create :fabric_tier, title: 'Fabric Tier' }

    it 'updates' do
      expect(fabric_tier.title).to eq 'Fabric Tier'
      expect(fabric_tier.fabric_tier_categories.count).to eq 0

      patch :update, id: fabric_tier.id,
        fabric_tier: { title: 'Updated Fabric Tier', fabric_tier_categories_attributes: { '0' => { fabric_category_id: fabric_category.id } } }, format: :js

      fabric_tier.reload

      expect(fabric_tier.title).to eq 'Updated Fabric Tier'
      expect(fabric_tier.fabric_tier_categories.count).to eq 1
    end

    it 'catches error due to not unique fabric_category_id on fabric_tier_category' do
      expect(fabric_tier.title).to eq 'Fabric Tier'
      expect(fabric_tier.fabric_tier_categories.count).to eq 0

      patch :update, id: fabric_tier.id,
        fabric_tier: { title: 'Updated Fabric Tier', fabric_tier_categories_attributes: {
           '0' => { fabric_category_id: fabric_category.id }, '1' => { fabric_category_id: fabric_category.id }
          }
        }, format: :js

      fabric_tier.reload

      expect(fabric_tier.title).to eq 'Fabric Tier'
      expect(fabric_tier.fabric_tier_categories.count).to eq 0
      expect(assigns(:fabric_tier).errors).to contain_exactly('Already selected category please be sure to add only one Tier Category per Fabric Category')
    end
  end

  describe 'PATCH #update_tier_category_price' do
    let(:fabric_tier) { create :fabric_tier, title: 'Fabric Tier' }

    context 'previously non-existing fabric_tier_category for selected fabric_tier' do
      it 'updates fabric_tier_category price' do
        expect(fabric_tier.title).to eq 'Fabric Tier'
        expect(fabric_tier.fabric_tier_categories.count).to eq 0

        patch :update_tier_category_price, id: fabric_tier.id, fabric_category_id: fabric_category.id, currency: 'GBP', value: 5

        fabric_tier.reload

        expect(fabric_tier.fabric_tier_categories.count).to eq 1
        expect(fabric_tier.fabric_tier_categories.first.price).to eq({ 'GBP' => '5' })
      end
    end

    context 'existing fabric_tier_category for selected fabric_tier' do
      let!(:fabric_tier_category) do
        create :fabric_tier_category, fabric_tier: fabric_tier, fabric_category: fabric_category, price: { 'GBP' => 13 }
      end

      it 'updates fabric_tier_category price' do
        expect(fabric_tier.title).to eq 'Fabric Tier'
        expect(fabric_tier.fabric_tier_categories.count).to eq 1

        patch :update_tier_category_price, id: fabric_tier.id, fabric_category_id: fabric_category.id, currency: 'GBP', value: 5

        fabric_tier.reload

        expect(fabric_tier.fabric_tier_categories.count).to eq 1
        expect(fabric_tier.fabric_tier_categories.first.price).to eq({ 'GBP' => '5' })
      end
    end
  end
end
