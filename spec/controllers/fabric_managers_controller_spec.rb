# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FabricManagersController, type: :controller do
  let(:user) { create :user, role: :admin }
  let!(:fabric_brand) { create :fabric_brand, title: 'Brand' }
  let!(:fabric_book) { create :fabric_book, title: 'Book' }
  let!(:fabric_info) { create :fabric_info, manufacturer_fabric_code: 'ISO8606', fabric_brand: fabric_brand, fabric_book: fabric_book }
  let!(:fabric_info2) { create :fabric_info, manufacturer_fabric_code: 'OSI8606' }

  before { sign_in user }

  describe 'POST #create' do
    let(:fabric_manager_params) { { manufacturer_fabric_code: fabric_info.manufacturer_fabric_code, status: :discontinued } }
    let(:fabric_manager_params2) do
      { manufacturer_fabric_code: fabric_info2.manufacturer_fabric_code, status: :out_of_stock, estimated_restock_date: Date.new(2007, 9, 1)  }
    end

    it 'creates with fabric brand and book' do
      expect(fabric_info.fabric_manager).to eq nil

      expect { post :create, fabric_manager: fabric_manager_params, format: :js }
        .to change { [FabricManager.count, FabricNotification.count] }.by [1, 1]

      fabric_info.reload

      fabric_manager = FabricManager.last

      expect(fabric_manager.manufacturer_fabric_code).to eq 'ISO8606'
      expect(fabric_manager.fabric_infos).to contain_exactly fabric_info
      expect(fabric_info.fabric_manager).to eq fabric_manager
      expect(fabric_manager.fabric_brand_id).to eq fabric_brand.id
      expect(fabric_manager.fabric_book_id).to eq fabric_book.id
      expect(fabric_manager.status).to eq 'discontinued'
    end

    it 'creates without fabric brand and book' do
      expect(fabric_info.fabric_manager).to eq nil

      expect { post :create, fabric_manager: fabric_manager_params2, format: :js }
        .to change { [FabricManager.count, FabricNotification.count] }.by [1, 1]

      fabric_info.reload

      fabric_manager = FabricManager.last

      expect(fabric_manager.manufacturer_fabric_code).to eq 'OSI8606'
      expect(fabric_manager.fabric_infos).to contain_exactly fabric_info2
      expect(fabric_info2.fabric_manager).to eq fabric_manager
      expect(fabric_manager.fabric_brand_id).to be nil
      expect(fabric_manager.fabric_book_id).to be nil
      expect(fabric_manager.status).to eq 'out_of_stock'
      expect(fabric_manager.estimated_restock_date).to eq '2007-09-01'
    end
  end

  describe 'PATCH #update' do
    let!(:fabric_manager) do
      create :fabric_manager, manufacturer_fabric_code: 'BD119', status: :out_of_stock, estimated_restock_date: Date.new(2007, 9, 1)
    end

    it 'updates and nulify estimated_restock_date' do
      expect(fabric_manager.manufacturer_fabric_code).to eq 'BD119'
      expect(fabric_manager.status).to eq 'out_of_stock'

      patch :update, id: fabric_manager.id,
        fabric_manager: { manufacturer_fabric_code: 'ISO8606', status: 'discontinued' }

      fabric_manager.reload

      expect(fabric_manager.fabric_infos).to contain_exactly fabric_info
      expect(fabric_info.fabric_manager).to eq fabric_manager
      expect(fabric_manager.manufacturer_fabric_code).to eq 'ISO8606'
      expect(fabric_manager.status).to eq 'discontinued'
      expect(fabric_manager.estimated_restock_date).to be nil
    end

    it 'updates' do
      expect(fabric_manager.manufacturer_fabric_code).to eq 'BD119'
      expect(fabric_manager.status).to eq 'out_of_stock'
      expect(FabricNotification.count).to eq 0

      patch :update, id: fabric_manager.id,
        fabric_manager: { manufacturer_fabric_code: 'OSI8606', status: 'out_of_stock' }

      fabric_manager.reload

      expect(fabric_manager.fabric_infos).to contain_exactly fabric_info2
      expect(fabric_info2.fabric_manager).to eq fabric_manager
      expect(fabric_manager.manufacturer_fabric_code).to eq 'OSI8606'
      expect(fabric_manager.status).to eq 'out_of_stock'
      expect(fabric_manager.estimated_restock_date).to eq '2007-09-01'
      expect(FabricNotification.count).to eq 1
    end
  end

  describe 'DELETE #destroy' do
    let!(:fabric_manager) do
      create :fabric_manager, manufacturer_fabric_code: 'BD119', status: :out_of_stock, estimated_restock_date: Date.new(2007, 9, 1)
    end

    it 'destroys fabric_manager' do
      expect(FabricManager.count).to eq 1
      expect(FabricNotification.count).to eq 0

      delete :destroy, id: fabric_manager.id, format: :js

      expect(FabricManager.count).to eq 0
      expect(FabricNotification.count).to eq 1
    end
  end
end
