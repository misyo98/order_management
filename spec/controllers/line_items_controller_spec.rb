# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LineItemsController, type: :controller do
  describe 'PATCH #tag' do
    let!(:item) { create :line_item }
    let!(:user) { create(:user) }
    let!(:tag) { create :tag, name: 'First' }
    let!(:tag1) { create :tag, name: 'Second' }
    before(:each) { sign_in user }

    context 'line item tags' do
      it 'assigns tags to line item' do
        patch :tags, format: :js, id: item, 'tags': [tag.name, tag1.name]

        item.reload

        expect(item.tags).to contain_exactly tag, tag1
      end

      it 'assigns non-existing tag and keeps already assigned tags' do
        expect { patch :tags, format: :js, id: item, 'tags': ['Third'] }
          .to change { [Tag.count, item.tags.count] }.by [3, 1]

        item.reload

        expect(item.tags.last.name).to match 'Third'
      end
    end
  end

  describe 'PATCH #update' do
    let!(:item) { create :line_item }
    let!(:user) { create(:user) }
    before(:each) { sign_in user }

    context 'line item comment update' do
      it 'changes comment of the item' do
        patch :update, id: item, line_item: attributes_for(
          :line_item, comment_for_tailor: 'Some comment')

        item.reload

        expect(response).to redirect_to item
        expect(item.comment_for_tailor).to eq 'Some comment'
      end
    end
  end
end
