# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FabricBrandsController, type: :controller do
  let(:user) { create :user }
  let(:fabric_brand_params) { { title: 'Fabric Brand' } }

  before { sign_in user }

  describe 'POST #create' do
    it 'creates' do
      expect { post :create, fabric_brand: fabric_brand_params }
        .to change { FabricBrand.count }.by 1

      fabric_brand = FabricBrand.last

      expect(fabric_brand.title).to eq 'Fabric Brand'
    end
  end

  describe 'PATCH #update' do
    let!(:fabric_brand) { create :fabric_brand }

    it 'updates' do
      patch :update, id: fabric_brand.id, fabric_brand: fabric_brand_params.merge(title: 'Updated Fabric Brand')

      fabric_brand.reload

      expect(fabric_brand.title).to eq 'Updated Fabric Brand'
    end
  end

  describe 'PATCH #reorder' do
    let!(:fabric_brand1) { create :fabric_brand, title: 'Brand 1' }
    let!(:fabric_brand2) { create :fabric_brand, title: 'Brand 2' }

    it 'reorders fabric_brands with empty orders' do
      expect(fabric_brand1.order).to be nil
      expect(fabric_brand2.order).to be nil

      patch :reorder, fabric_brand: [ fabric_brand2.id, fabric_brand1.id], format: :js

      [fabric_brand1, fabric_brand2].each(&:reload)

      expect(fabric_brand1.order).to eq 2
      expect(fabric_brand2.order).to eq 1
    end

    it 'reorders fabric_brands with empty orders' do
      fabric_brand1.update_column(:order, 2)
      fabric_brand2.update_column(:order, 1)

      expect(fabric_brand1.order).to eq 2
      expect(fabric_brand2.order).to eq 1

      patch :reorder, fabric_brand: [ fabric_brand1.id, fabric_brand2.id], format: :js

      [fabric_brand1, fabric_brand2].each(&:reload)

      expect(fabric_brand1.order).to eq 1
      expect(fabric_brand2.order).to eq 2
    end
  end
end
