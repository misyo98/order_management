# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FabricBooksController, type: :controller do
  let(:user) { create :user }
  let(:fabric_book_params) { { title: 'Fabric Book' } }

  before { sign_in user }

  describe 'POST #create' do
    it 'creates' do
      expect { post :create, fabric_book: fabric_book_params, format: :html }
        .to change { FabricBook.count }.by 1

      fabric_book = FabricBook.last

      expect(fabric_book.title).to eq 'Fabric Book'
    end
  end

  describe 'PATCH #update' do
    let!(:fabric_book) { create :fabric_book }

    it 'updates' do
      patch :update, id: fabric_book.id, fabric_book: fabric_book_params.merge(title: 'Updated Fabric Book')

      fabric_book.reload

      expect(fabric_book.title).to eq 'Updated Fabric Book'
    end
  end

  describe 'PATCH #reorder' do
    let!(:fabric_book1) { create :fabric_book, title: 'Book 1' }
    let!(:fabric_book2) { create :fabric_book, title: 'Book 2' }

    it 'reorders fabric_books with empty orders' do
      expect(fabric_book1.order).to be nil
      expect(fabric_book2.order).to be nil

      patch :reorder, fabric_book: [ fabric_book2.id, fabric_book1.id], format: :js

      [fabric_book1, fabric_book2].each(&:reload)

      expect(fabric_book1.order).to eq 2
      expect(fabric_book2.order).to eq 1
    end

    it 'reorders fabric_books with empty orders' do
      fabric_book1.update_column(:order, 2)
      fabric_book2.update_column(:order, 1)

      expect(fabric_book1.order).to eq 2
      expect(fabric_book2.order).to eq 1

      patch :reorder, fabric_book: [ fabric_book1.id, fabric_book2.id], format: :js

      [fabric_book1, fabric_book2].each(&:reload)

      expect(fabric_book1.order).to eq 1
      expect(fabric_book2.order).to eq 2
    end
  end
end
