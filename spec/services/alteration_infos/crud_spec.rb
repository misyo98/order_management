# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AlterationInfos::CRUD do
  describe '#create' do
    let!(:profile) { create :profile }
    let!(:category1) { create :category, name: 'First category' }
    let!(:category2) { create :category, name: 'Second category' }
    let(:params) do
      {
        alteration_infos: {
          "#{category1.id}": {
            lapel_flaring: 'yes',
            shoulder_fix: 'no',
            comment: 'actual comment',
            manufacturer_code: 'PESB19100005',
            category_id: "#{category1.id}",
            profile_id: "#{profile.id}",
            id: ''
          },
          "#{category2.id}": {
            lapel_flaring: 'no',
            shoulder_fix: 'yes',
            comment: '',
            manufacturer_code: 'PESB19100005',
            category_id: "#{category2.id}",
            profile_id: "#{profile.id}",
            id: ''
          }
        }
      }
    end


    context 'alteration infos' do
      subject(:create_infos) { described_class.new(params: params, altered_category_ids: [category1.id, category2.id]).create }

      it 'creates alteration_infos' do
        expect { create_infos }.to change { AlterationInfo.count }.by 2

        info1, info2 = AlterationInfo.first, AlterationInfo.last

        expect(info1.lapel_flaring).to eq 'yes'
        expect(info1.shoulder_fix).to eq 'no'
        expect(info1.comment).to eq 'actual comment'
        expect(info1.manufacturer_code).to eq 'PESB19100005'
        expect(info1.category_id).to eq category1.id
        expect(info1.profile_id).to eq profile.id
        expect(info2.lapel_flaring).to eq 'no'
        expect(info2.shoulder_fix).to eq 'yes'
        expect(info2.comment).to eq ''
        expect(info2.manufacturer_code).to eq 'PESB19100005'
        expect(info2.category_id).to eq category2.id
        expect(info2.profile_id).to eq profile.id
      end
    end

    context 'alteration infos with comment for alteration without changes to final profile' do
      subject(:create_infos) do
        described_class.new(
          params: params.merge!(save_without_changes: 'present'),
          altered_category_ids: [category1.id, category2.id]
        ).create
      end

      it 'creates alteration_infos with adjusted comment' do
        expect { create_infos }.to change { AlterationInfo.count }.by 2

        info1, info2 = AlterationInfo.first, AlterationInfo.last

        expect(info1.lapel_flaring).to eq 'yes'
        expect(info1.shoulder_fix).to eq 'no'
        expect(info1.comment).to eq 'actual comment - Saved without changes to final profile.'
        expect(info1.manufacturer_code).to eq 'PESB19100005'
        expect(info1.category_id).to eq category1.id
        expect(info1.profile_id).to eq profile.id
        expect(info2.lapel_flaring).to eq 'no'
        expect(info2.shoulder_fix).to eq 'yes'
        expect(info2.comment).to eq ' - Saved without changes to final profile.'
        expect(info2.manufacturer_code).to eq 'PESB19100005'
        expect(info2.category_id).to eq category2.id
        expect(info2.profile_id).to eq profile.id
      end
    end
  end
end
