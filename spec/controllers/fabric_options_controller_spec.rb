# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FabricOptionsController, type: :controller do
  let(:user) { create :user }
  let(:fabric_tab) { create :fabric_tab, title: 'Fabric Tab' }
  let(:fabric_option_params) do
    {
      fabric_tab_id: fabric_tab.id,
      title: 'Fabric Option',
      order: 1,
      button_type: :dropdown_button,
      placeholder: 'Placeholder text',
      outfitter_selection: :os_all,
      tuxedo: :tuxedo_all,
      premium: :premium_all,
      fusible: :fusible_all,
      manufacturer: :all_m
    }
  end

  before { sign_in user }

  describe 'POST #create' do
    it 'creates' do
      expect { post :create, fabric_option: fabric_option_params }
        .to change { FabricOption.count }.by 1

      fabric_option = FabricOption.last

      expect(fabric_option.fabric_tab_id).to eq fabric_tab.id
      expect(fabric_option.title).to eq 'Fabric Option'
      expect(fabric_option.order).to eq 1
      expect(fabric_option.button_type).to eq 'dropdown_button'
      expect(fabric_option.placeholder).to eq 'Placeholder text'
      expect(fabric_option.outfitter_selection).to eq 'os_all'
      expect(fabric_option.tuxedo).to eq 'tuxedo_all'
      expect(fabric_option.premium).to eq 'premium_all'
      expect(fabric_option.fusible).to eq 'fusible_all'
      expect(fabric_option.manufacturer).to eq 'all_m'
    end
  end

  describe 'PATCH #update' do
    let(:fabric_option) { create :fabric_option, title: 'Fabric Option' }
    let(:fabric_tab) { create :fabric_tab }

    it 'updates' do
      expect(fabric_option.title).to eq 'Fabric Option'
      expect(fabric_option.fabric_tab_id).to be nil
      expect(fabric_option.order).to eq 1

      patch :update, id: fabric_option.id, fabric_option: {
        title: 'Updated Fabric Option', fabric_tab_id: fabric_tab.id, order: 2
      }

      fabric_option.reload

      expect(fabric_option.title).to eq 'Updated Fabric Option'
      expect(fabric_option.fabric_tab_id).to eq fabric_tab.id
      expect(fabric_option.order).to eq 2
    end
  end

  describe 'PATCH#reorder' do
    let!(:fabric_tab) { create :fabric_tab, title: 'Fabric Tab' }
    let!(:fabric_option_1) { create :fabric_option, fabric_tab: fabric_tab, title: 'Fabric Option 1', order: 1 }
    let!(:fabric_option_2) { create :fabric_option, fabric_tab: fabric_tab, title: 'Fabric Option 2', order: 2 }
    let!(:fabric_option_3) { create :fabric_option, fabric_tab: fabric_tab, title: 'Fabric Option 3', order: 3 }

    it 'does reorder fabric_options' do
      patch :reorder, parent_id: fabric_tab.id, fabric_option: [fabric_option_3.id, fabric_option_2.id, fabric_option_1.id], format: :js

      fabric_option_1.reload
      fabric_option_2.reload
      fabric_option_3.reload

      expect(fabric_option_1.order).to eq 3
      expect(fabric_option_2.order).to eq 2
      expect(fabric_option_3.order).to eq 1
      expect(fabric_tab.fabric_options.order(:order).pluck(:order))
        .to contain_exactly(fabric_option_3.order, fabric_option_2.order, fabric_option_1.order)
    end
  end
end
