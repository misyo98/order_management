# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FabricBookDecorator, type: :decorator do
  describe '#fabric_infos_id_links' do
    let(:fabric_book) { create :fabric_book, title: 'Fabric Book' }
    let(:fabric_brand) { create :fabric_brand, title: 'Fabric Brand' }

    subject(:book_infos_id_links) { described_class.decorate(fabric_book).fabric_infos_id_links }
    subject(:brand_infos_id_links) { described_class.decorate(fabric_brand).fabric_infos_id_links }

    context 'fabric_book was is not used for any fabric_info' do
      it 'returns fabric_info ids' do

        expect(book_infos_id_links).to eq 'Was not used anywhere'
      end
    end

    context 'fabric_book is used for some fabric_infos' do
      let!(:fabric_info) { create :fabric_info, fabric_book: fabric_book }
      let!(:fabric_info2) { create :fabric_info, fabric_book: fabric_book }

      it 'returns fabric_info ids' do
        expect(book_infos_id_links).to match "<a href=\"/fabric_infos/#{fabric_info.id}\">#{fabric_info.id}</a>"
        expect(book_infos_id_links).to match "<a href=\"/fabric_infos/#{fabric_info2.id}\">#{fabric_info2.id}</a>"
      end
    end

    context 'fabric_brand is not used for any fabric_info' do
      it 'returns fabric_info ids' do
        expect(brand_infos_id_links).to eq 'Was not used anywhere'
      end
    end

    context 'fabric_brand is used for some fabric_infos' do
      let!(:fabric_info) { create :fabric_info, fabric_brand: fabric_brand }
      let!(:fabric_info2) { create :fabric_info, fabric_brand: fabric_brand }

      it 'returns fabric_info ids' do
        expect(brand_infos_id_links).to match "<a href=\"/fabric_infos/#{fabric_info.id}\">#{fabric_info.id}</a>"
        expect(brand_infos_id_links).to match "<a href=\"/fabric_infos/#{fabric_info2.id}\">#{fabric_info2.id}</a>"
      end
    end
  end

  describe '#archived_field' do
    context 'fabric_book' do
      let(:fabric_book) { create :fabric_book, title: 'Fabric Book' }

      subject { described_class.decorate(fabric_book).archived_field }

      it 'returns No for present fabric_book' do
        expect(subject).to eq 'No'
      end

      it 'returns formatted time of archivation' do
        fabric_book.destroy

        expect(subject).to eq "Archived: #{fabric_book.deleted_at}"
      end
    end

    context 'fabric_brand' do
      let(:fabric_brand) { create :fabric_brand, title: 'Fabric Brand' }

      subject { described_class.decorate(fabric_brand).archived_field }

      it 'returns No for present fabric_brand' do
        expect(subject).to eq 'No'
      end

      it 'returns formatted time of archivation' do
        fabric_brand.destroy

        expect(subject).to eq "Archived: #{fabric_brand.deleted_at}"
      end
    end
  end
end
