# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AlterationSummary, type: :model do
  describe '.unique_summaries' do
    let(:tailor) { create :alteration_tailor }
    let(:item) { create :line_item, alteration_tailor_id: tailor.id, state: 'being_altered' }
    let(:summary1) { create :alteration_summary }
    let(:summary2) { create :alteration_summary }
    let!(:summary_items1) { create :alteration_summary_line_item, line_item: item, alteration_summary: summary1 }
    let!(:summary_items2) { create :alteration_summary_line_item, line_item: item, alteration_summary: summary2 }

    subject { described_class.joins(:items).unique_summaries }
    it { is_expected.to contain_exactly summary2 }
   end

   describe '#summary_order' do
     let(:order) { create :order }
     let(:item) { create :line_item, order_id: order.id }
     let(:summary1) { create :alteration_summary }
     let(:summary2) { create :alteration_summary }
     let!(:summary_items) { create :alteration_summary_line_item, line_item: item, alteration_summary: summary1 }

     context 'with linked line_items' do
       subject(:order_of_the_summary) { summary1.summary_order }

       it 'returns order_id' do
         expect(summary1.alteration_summary_line_items.any?).to be true

         expect(order_of_the_summary).to eq order.id
       end
     end

     context 'without linked line_items' do
       subject(:order_of_the_summary) { summary2.summary_order }

       it 'returns nil' do
         expect(summary2.alteration_summary_line_items).to be_empty

         expect(order_of_the_summary).to be nil
       end
     end
   end
end
