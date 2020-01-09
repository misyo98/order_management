# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FabricTabsController, type: :controller do
  let(:user) { create :user }
  let(:fabric_category) { create :fabric_category, title: 'Fabric Category' }

  before { sign_in user }

  describe 'POST #create' do
    let(:fabric_tab_params) { { fabric_category_id: fabric_category.id, title: 'Fabric Tab', order: 1 } }

    it 'creates' do
      expect { post :create, fabric_tab: fabric_tab_params }
        .to change { FabricTab.count }.by 1

      fabric_tab = FabricTab.last

      expect(fabric_tab.fabric_category_id).to eq fabric_category.id
      expect(fabric_tab.title).to eq 'Fabric Tab'
      expect(fabric_tab.order).to eq 1
    end
  end

  describe 'PATCH #update' do
    let(:fabric_tab) { create :fabric_tab, title: 'Fabric Tab'}

    it 'updates' do
      expect(fabric_tab.fabric_category_id).to be nil
      expect(fabric_tab.title).to eq 'Fabric Tab'

      patch :update, id: fabric_tab.id,
        fabric_tab: { fabric_category_id: fabric_category.id, title: 'Updated Fabric Tab' }

      fabric_tab.reload

      expect(fabric_tab.fabric_category_id).to eq fabric_category.id
      expect(fabric_tab.title).to eq 'Updated Fabric Tab'
    end
  end

  describe 'PATCH#reorder' do
    let(:fabric_tab_1) { create :fabric_tab, fabric_category: fabric_category, title: 'Fabric Tab 1', order: 1 }
    let(:fabric_tab_2) { create :fabric_tab, fabric_category: fabric_category, title: 'Fabric Tab 2', order: 2 }
    let(:fabric_tab_3) { create :fabric_tab, fabric_category: fabric_category, title: 'Fabric Tab 3', order: 3 }

    it 'does reorder fabric_tabs' do
      patch :reorder, parent_id: fabric_category.id, fabric_tab: [fabric_tab_3.id, fabric_tab_2.id, fabric_tab_1.id], format: :js

      fabric_tab_1.reload
      fabric_tab_2.reload
      fabric_tab_3.reload

      expect(fabric_tab_1.order).to eq 3
      expect(fabric_tab_2.order).to eq 2
      expect(fabric_tab_3.order).to eq 1
      expect(fabric_category.fabric_tabs.order(:order).pluck(:order))
        .to contain_exactly(fabric_tab_3.order, fabric_tab_2.order, fabric_tab_1.order)
    end
  end
end
