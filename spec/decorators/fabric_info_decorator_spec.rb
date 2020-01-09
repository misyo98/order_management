# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FabricInfoDecorator, type: :decorator do
  let!(:fabric_book) { create :fabric_book, title: 'Fabric Book' }
  let!(:fabric_brand) { create :fabric_brand, title: 'Fabric Brand' }
  let!(:fabric_tier) { create :fabric_tier, title: 'Fabric Tier' }
  let!(:fabric_info) { create :fabric_info, fabric_book: fabric_book, fabric_brand: fabric_brand, fabric_tier: fabric_tier }
  let!(:user) { create :user, first_name: 'Admin', last_name: 'User', role: :admin }
  let!(:user2) { create :user, first_name: 'Outfitter', last_name: 'User', role: :outfitter }

  describe '#fabric_book_field' do
    before do
      sign_in user
    end

    subject(:fabric_book_field) { described_class.decorate(fabric_info).fabric_book_field }

    context 'for admin user' do

      it 'returns link to fabric_book' do
        expect(fabric_book_field).to eq "<span id=\"fabric_info_#{fabric_info.id}_fabric_book\"><a href=\"/fabric_books/#{fabric_book.id}\">#{fabric_book.id}</a></span>"
      end
    end

    context 'for outfitter user' do
      before do
        sign_in user2
      end

      it 'returns link to fabric_book' do
        expect(fabric_book_field).to eq fabric_book.title
      end
    end

    it 'returns empty space when there is no fabric_book' do
      fabric_info.update_column(:fabric_book_id, nil)

      expect(fabric_book_field).to eq "<span id=\"fabric_info_#{fabric_info.id}_fabric_book\"></span>"
    end
  end

  describe '#fabric_brand_field' do
    before do
      sign_in user
    end

    subject(:fabric_brand_field) { described_class.decorate(fabric_info).fabric_brand_field }

    context 'for admin user' do

      it 'returns link to fabric_brand' do
        expect(fabric_brand_field).to eq "<span id=\"fabric_info_#{fabric_info.id}_fabric_brand\"><a href=\"/fabric_brands/#{fabric_brand.id}\">#{fabric_brand.id}</a></span>"
      end
    end

    context 'for outfitter user' do
      before do
        sign_in user2
      end

      it 'returns link to fabric_brand' do
        expect(fabric_brand_field).to eq fabric_brand.title
      end
    end

    it 'returns empty space when there is no fabric_brand' do
      fabric_info.update_column(:fabric_brand_id, nil)

      expect(fabric_brand_field).to eq "<span id=\"fabric_info_#{fabric_info.id}_fabric_brand\"></span>"
    end
  end

  describe '#fabric_tier_field' do
    before do
      sign_in user
    end

    subject(:fabric_tier_field) { described_class.decorate(fabric_info).fabric_tier_field }

    before do
      sign_in user2
    end

    it 'returns link to fabric_tier' do
      expect(fabric_tier_field).to match "data-remote=\"true\" href=\"/fabric_infos/#{fabric_info.id}/fabric_tier_prices\">Tier Prices</a></span>"
    end

    it 'returns empty space when there is no fabric_tier' do
      fabric_info.update_column(:fabric_tier_id, nil)

      expect(fabric_tier_field).to be_nil
    end
  end

  describe '#oos_or_discontinued_field' do
    let!(:fabric_manager) { create :fabric_manager, fabric_infos: [fabric_info], status: :out_of_stock, estimated_restock_date: Date.current }

    subject(:oos_or_discontinued_field) { described_class.decorate(fabric_info).oos_or_discontinued_field }

    it 'returns OOS label with estimated_restock_date' do
      expect(oos_or_discontinued_field).to eq "OOS (restock date #{Date.current.to_date})"
    end

    it 'returns OOS label with undetermined date' do
      fabric_manager.update_column(:estimated_restock_date, nil)

      expect(oos_or_discontinued_field).to eq 'OOS (restock date undetermined)'
    end

    it 'returns Discontinued label' do
      fabric_manager.update(status: :discontinued)

      expect(oos_or_discontinued_field).to eq 'Discontinued'
    end

    it 'returns nothing if there is on fabric_manager assinged' do
      fabric_manager.destroy

      expect(oos_or_discontinued_field).to be_empty
    end
  end
end
