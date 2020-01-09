# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LineItems::DestroyMeta do
  let(:meta_hash) { { label: 'Test', key: 'Test', value: '123'} }
  let(:item) { create :line_item, meta: [meta_hash.stringify_keys] }

  describe '.call' do
    subject { described_class.(item, meta_hash) }

    it 'removes meta field' do
      expect(item.meta).to contain_exactly meta_hash.stringify_keys

      subject

      expect(item.meta).to be_empty
    end
  end
end
