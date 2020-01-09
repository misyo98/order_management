# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LineItems::TriggerRemake do
  describe '.call' do
    let!(:pants_category) { create :category, name: 'Pants' }
    let!(:jacket_category) { create :category, name: 'Jacket' }
    let(:suits_product) { create :product, category: 'MADE-TO-MEASURE SUITS' }
    let(:line_item) { create :line_item, state: :completed, product: suits_product }
    let(:altered_categories) { [pants_category.name, jacket_category.name] }

    subject { described_class.(line_item.id, altered_categories, nil) }

    it 'triggers remake' do
      expect(line_item.state).to eq 'completed'
      subject

      line_item.reload

      expect(line_item.state).to eq 'remake_requested'
      expect(line_item.remake_category).to be_empty
    end

    context 'when not all item categories are being remade' do
      let(:altered_categories) { [jacket_category.name] }

      it 'assigns remake category and triggers remake' do
        expect(line_item.state).to eq 'completed'

        expect { subject }.to change { LineItem.count }.by 1

        line_item.reload

        expect(line_item.state).to eq 'completed'
        expect(line_item.remake_category).to match_array ['Jacket']
      end
    end

    context 'when not both suit categories are being remade' do
      let!(:jacket_remake_product) { create :product, title: 'Jacket Remake', sku: 'ES_JACKET_APP', category: 'MADE-TO-MEASURE JACKETS' }
      let(:altered_categories) { [jacket_category.name] }
      let!(:line_item2) { create :line_item, state: :completed, name: 'Suit', product: suits_product }

      subject { described_class.(line_item2.id, altered_categories, nil) }

      it 'triggers partial remake for suit item' do
        expect { subject }.to change { LineItem.count }.by 1

        line_item2.reload

        expect(line_item2.state).to eq 'completed'
        expect(line_item2.remake_category).to match_array ['Jacket']
        expect(LineItem.last.name).to eq 'Jacket - All Fabrics (Appointment Selection)'
        expect(LineItem.last.sku).to eq 'ES_JACKET_APP'
        expect(LineItem.last.product.sku).to eq 'ES_JACKET_APP'
        expect(LineItem.last.product.title).to eq 'Jacket Remake'
        expect(LineItem.last.product_category).to eq 'MADE-TO-MEASURE JACKETS'
      end
    end

    context 'ordered_fabric field for fully remade item' do
      let(:line_item) { create :line_item, state: :completed, product: suits_product, ordered_fabric: true, fabric_tracking_number: 'test123' }
      let(:line_item2) { create :line_item, state: :completed, product: suits_product, ordered_fabric: true }
      let(:altered_categories) { [pants_category.name, jacket_category.name] }

      subject { described_class.(line_item.id, altered_categories, nil) }

      it 'triggers remake and nullify ordered_fabric field' do
        expect(line_item.state).to eq 'completed'
        expect(line_item.ordered_fabric?).to be true

        subject

        line_item.reload

        expect(line_item.state).to eq 'remake_requested'
        expect(line_item.remake_category).to be_empty
        expect(line_item.ordered_fabric?).to be true
        expect(line_item.fabric_tracking_number).to eq 'test123'
      end
    end

    context 'ordered_fabric field for partially remade item' do
      let!(:jacket_remake_product) { create :product, title: 'Jacket Remake', sku: 'ES_JACKET_APP', category: 'MADE-TO-MEASURE JACKETS' }
      let(:altered_categories) { [jacket_category.name] }
      let!(:line_item2) { create :line_item, state: :completed, name: 'Suit', product: suits_product, ordered_fabric: true }

      subject { described_class.(line_item2.id, altered_categories, nil) }

      it 'triggers remake and nullify ordered_fabric field for new remake item' do
        expect { subject }.to change { LineItem.count }.by 1

        line_item2.reload

        remake_item = LineItem.last

        expect(line_item2.state).to eq 'completed'
        expect(line_item2.remake_category).to match_array ['Jacket']
        expect(line_item2.ordered_fabric?).to be true
        expect(remake_item.name).to eq 'Jacket - All Fabrics (Appointment Selection)'
        expect(remake_item.sku).to eq 'ES_JACKET_APP'
        expect(remake_item.product.sku).to eq 'ES_JACKET_APP'
        expect(remake_item.product.title).to eq 'Jacket Remake'
        expect(remake_item.product_category).to eq 'MADE-TO-MEASURE JACKETS'
        expect(remake_item.ordered_fabric?).to be false
      end
    end
  end
end
