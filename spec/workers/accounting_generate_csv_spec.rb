# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountingGenerateCsv, type: :job do
  describe 'csv file generator' do
    let(:order) { create :order }
    let!(:item) { create :line_item, order: order, state: 'waiting_for_items_alteration' }

    it 'adds file' do
      expect { described_class.perform_async }.to change { Sidekiq::Worker.jobs.size }.by 1
      expect { described_class.new.perform(item.name) }.to change { TempFile.count }.by 1
    end

    it 'removes file' do
      file = TempFile.create(attachment: 'some.csv')
      expect { CleanDownloadedTempFiles.new.perform(id: file.id) }.to change { TempFile.count }.by -1
    end
  end
end
