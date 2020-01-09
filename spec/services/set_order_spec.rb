# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SetOrder do
  let!(:fabric_book1) { create :fabric_book, title: 'Book 1' }
  let!(:fabric_book2) { create :fabric_book, title: 'Book 2' }
  let!(:fabric_brand1) { create :fabric_brand, title: 'Brand 1' }
  let!(:fabric_brand2) { create :fabric_brand, title: 'Brand 2' }
  let(:fabric_book_table) { :fabric_book }
  let(:fabric_brand_table) { :fabric_brand }

  context 'fabric_book' do
    subject { described_class.(items: [fabric_book2.id, fabric_book1.id], table_name: fabric_book_table) }

    it 'reorders fabric_books' do
      expect(fabric_book1.order).to be nil
      expect(fabric_book2.order).to be nil

      subject

      [fabric_book1, fabric_book2].each(&:reload)

      expect(fabric_book1.order).to eq 2
      expect(fabric_book2.order).to eq 1
    end
  end

  context 'fabric_brand' do
    subject { described_class.(items: [fabric_brand1.id, fabric_brand2.id], table_name: fabric_brand_table) }

    it 'reorders fabric_books' do
      expect(fabric_brand1.order).to be nil
      expect(fabric_brand2.order).to be nil

      subject

      [fabric_brand1, fabric_brand2].each(&:reload)

      expect(fabric_brand1.order).to eq 1
      expect(fabric_brand2.order).to eq 2
    end
  end

  context 'invalid table name' do
    subject { described_class.(items: [fabric_brand1.id, fabric_brand2.id], table_name: 'dummy table') }

    it 'does no changes' do
      expect(fabric_brand1.order).to be nil
      expect(fabric_brand2.order).to be nil

      subject

      [fabric_brand1, fabric_brand2].each(&:reload)

      expect(fabric_brand1.order).to be nil
      expect(fabric_brand2.order).to be nil
    end
  end

  context 'no items given' do
    subject { described_class.(items: [], table_name: fabric_book_table) }

    it 'does no changes' do
      expect(fabric_book1.order).to be nil
      expect(fabric_book2.order).to be nil

      subject

      [fabric_brand1, fabric_brand2].each(&:reload)

      expect(fabric_book1.order).to be nil
      expect(fabric_book2.order).to be nil
    end
  end
end
