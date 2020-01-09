# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FabricCategoriesController, type: :controller do
  let(:user) { create :user }

  before { sign_in user }

  describe 'POST #create' do
    it 'creates' do
      expect { post :create, fabric_category: { title: 'Fabric Category', tuxedo: true, tuxedo_price: { 'GBP' => 5, 'SGD' => 4 } } }
        .to change { FabricCategory.count }.by 1

      fabric_category = FabricCategory.last

      expect(fabric_category.title).to eq 'Fabric Category'
      expect(fabric_category.tuxedo).to be true
      expect(fabric_category.tuxedo_price).to eq({ 'GBP'=>'5', 'SGD'=>'4' })
    end
  end

  describe 'PATCH #update' do
    let(:fabric_category) { create :fabric_category, title: 'Fabric Category' }

    context 'regular update' do
      it 'updates' do
        expect(fabric_category.title).to eq 'Fabric Category'

        patch :update, id: fabric_category.id, fabric_category: { title: 'Updated Fabric Category', tuxedo: true, tuxedo_price: { 'GBP' => 5, 'SGD' => 4 } }

        fabric_category.reload

        expect(fabric_category.title).to eq 'Updated Fabric Category'
        expect(fabric_category.tuxedo).to be true
        expect(fabric_category.tuxedo_price).to eq({ 'GBP'=>'5', 'SGD'=>'4' })
      end
    end

    context 'removing tuxedo' do
      it 'updates and setting tuxedo_price to nil for non-tuxedo category' do
        expect(fabric_category.title).to eq 'Fabric Category'

        patch :update, id: fabric_category.id, fabric_category: { title: 'Newly Fabric Category', tuxedo: false }

        fabric_category.reload

        expect(fabric_category.title).to eq 'Newly Fabric Category'
        expect(fabric_category.tuxedo).to be false
        expect(fabric_category.tuxedo_price).to be nil
      end
    end
  end
end
