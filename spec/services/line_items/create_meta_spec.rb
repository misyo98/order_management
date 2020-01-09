# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LineItems::CreateMeta do
  let(:item) { create :line_item }
  let(:meta_hash) { { label: 'Test', key: 'Test', value: '123' } }

  describe '.call' do
    subject { described_class.(item, meta_hash) }

    it 'adds new meta field' do
      result = subject
      added_meta = item.meta.last

      expect(result.success?).to be true
      expect(added_meta['label']).to eq 'Test'
      expect(added_meta['key']).to eq 'Test'
      expect(added_meta['value']).to eq '123'
    end
  end
end
