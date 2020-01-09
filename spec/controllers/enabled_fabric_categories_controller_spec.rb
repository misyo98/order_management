# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EnabledFabricCategoriesController, type: :controller do
  let(:fabric_info) { create :fabric_info }
  let(:fabric_category) { create :fabric_category, title: 'Fabric Category' }
  let(:user) { create :user }

  before { sign_in user }

  describe 'POST #create' do
    it 'creates' do
      expect { post :create, enabled_fabric_category: { fabric_info_id: fabric_info.id, fabric_category_id: fabric_category.id } }
        .to change { EnabledFabricCategory.count }.by 1

      enabled_fabric_category = EnabledFabricCategory.last

      expect(enabled_fabric_category.fabric_info_id).to eq fabric_info.id
      expect(enabled_fabric_category.fabric_category_id).to eq fabric_category.id
    end
  end

  describe 'PATCH #update' do
    let(:fabric_info) { create :fabric_info }
    let(:fabric_category) { create :fabric_category, title: 'Fabric Category' }
    let(:enabled_fabric_category) { create :enabled_fabric_category }

    it 'updates' do
      expect(enabled_fabric_category.fabric_info_id).to be nil
      expect(enabled_fabric_category.fabric_category_id).to be nil

      patch :update, id: enabled_fabric_category.id,
        enabled_fabric_category: { fabric_info_id: fabric_info.id, fabric_category_id: fabric_category.id }

      enabled_fabric_category.reload

      expect(enabled_fabric_category.fabric_info_id).to eq fabric_info.id
      expect(enabled_fabric_category.fabric_category_id).to eq fabric_category.id
    end
  end
end
