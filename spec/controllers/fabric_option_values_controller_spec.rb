# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FabricOptionValuesController, type: :controller do
  let(:user) { create :user }
  let(:fabric_option) { create :fabric_option, title: 'Fabric Option' }
  let(:fabric_option_value_params) do
    {
      fabric_option_id: fabric_option.id,
      title: 'Fabric Option Value',
      order: 1,
      tuxedo: :tuxedo_no,
      premium: :premium_yes,
      manufacturer: :old_m
    }
  end
  let(:price_params) { [{ currency: 'GBP', value: 10 }] }

  before { sign_in user }

  describe 'POST #create' do
    it 'creates' do
      expect { post :create, fabric_option_value: fabric_option_value_params, price_array: price_params }
        .to change { FabricOptionValue.count }.by 1

      fabric_option_value = FabricOptionValue.last

      expect(fabric_option_value.fabric_option_id).to eq fabric_option.id
      expect(fabric_option_value.title).to eq 'Fabric Option Value'
      expect(fabric_option_value.order).to eq 1
      expect(fabric_option_value.price).to eq({ 'GBP' => '10' })
      expect(fabric_option_value.tuxedo).to eq 'tuxedo_no'
      expect(fabric_option_value.premium).to eq 'premium_yes'
      expect(fabric_option_value.manufacturer).to eq "old_m"
    end
  end

  describe 'PATCH #update' do
    let!(:fabric_option_value) { create :fabric_option_value, title: 'Fabric Option Value', premium: :premium_no, manufacturer: :old_m, active: false }
    let!(:faric_option) { create :fabric_option, title: 'Fabric Option' }

    context 'regualar update' do
      it 'updates' do
        patch :update, id: fabric_option_value.id,
        fabric_option_value: {
          fabric_option_id: fabric_option.id,
          title: 'Updated Fabric Option Value',
          premium: :premium_all,
          manufacturer: :new_m,
          active: true
        },
        price_array: price_params.push({ currency: 'GBP', value: 20 })

        [fabric_option_value, fabric_option.reload].each(&:reload)

        expect(fabric_option_value.fabric_option_id).to be fabric_option.id
        expect(fabric_option_value.title).to eq 'Updated Fabric Option Value'
        expect(fabric_option_value.price).to eq({ 'GBP' => '20' })
        expect(fabric_option_value.premium).to eq 'premium_all'
        expect(fabric_option_value.manufacturer).to eq 'new_m'
        expect(fabric_option_value.active).to be true
        expect(fabric_option.fabric_option_values.count).to eq 1
      end
    end

    context 'best_in_place update' do
      it 'updates' do
        patch :update, id: fabric_option_value.id,
        fabric_option_value: {
          active: true
        },
        bip_update: true

        fabric_option_value.reload

        expect(fabric_option_value.active).to be true
      end
    end
  end

  describe 'PATCH#reorder' do
    let!(:fabric_option) { create :fabric_option, title: 'Fabric Option' }
    let!(:fabric_option_value_1) { create :fabric_option_value, fabric_option: fabric_option, title: 'Fabric Option Value 1', order: 1 }
    let!(:fabric_option_value_2) { create :fabric_option_value, fabric_option: fabric_option, title: 'Fabric Option Value 2', order: 2 }
    let!(:fabric_option_value_3) { create :fabric_option_value, fabric_option: fabric_option, title: 'Fabric Option Value 3', order: 3 }

    it 'does reorder fabric_option_values' do
      patch :reorder, parent_id: fabric_option.id, fabric_option_value: [fabric_option_value_3.id, fabric_option_value_2.id, fabric_option_value_1.id], format: :js

      [fabric_option_value_1, fabric_option_value_2, fabric_option_value_3].each(&:reload)

      expect(fabric_option_value_1.order).to eq 3
      expect(fabric_option_value_2.order).to eq 2
      expect(fabric_option_value_3.order).to eq 1
      expect(fabric_option.fabric_option_values.order(:order).pluck(:order))
        .to contain_exactly(fabric_option_value_3.order, fabric_option_value_2.order, fabric_option_value_1.order)
    end
  end
end
