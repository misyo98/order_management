# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LineItems::TriggerState do
  describe '.call' do
    let(:order) { create :order }
    let(:current_user) { create :user }
    let(:event) { :trigger_manufacturing }
    let(:line_item) { create :line_item, state: :new, order: order, manufacturer: 1 }
    let(:params) { { id: line_item.id, state_event: event, user_id: current_user.id } }

    subject { described_class.(params) }

    it 'triggers item to proper state' do
      expect(line_item.state).to eq 'new'

      subject

      line_item.reload
      expect(line_item.state).to eq 'no_measurement_profile'
      expect(subject.item).to eq line_item
      expect(subject.items_for_mass_update).to be_empty
    end

    context 'invalid state change' do
      let(:event) { :call_mama }

      it 'does not trigger the state' do
        expect(line_item.state).to eq 'new'

        subject

        line_item.reload
        expect(line_item.state).to eq 'new'
        expect(subject.item).to eq line_item
        expect(subject.items_for_mass_update).to be_empty
      end
    end

    context 'items with gift category or blank manufacturer' do
      let(:gift_product) { create :product, category: 'GIFT CARD' }
      let(:event) { :trigger_manufacturing }
      let(:event1) { :prepare_shipment }
      let(:line_item) { create :line_item, state: :new, order: order, manufacturer: 0 }
      let(:gift_item) { create :line_item, state: :new, order: order, product: gift_product, manufacturer: 0 }
      let(:params) { { id: line_item.id, state_event: event, user_id: current_user.id } }
      let(:params1) { { id: gift_item.id, state_event: event1, user_id: current_user.id } }

      subject(:trigger_empty_manufacturer_item!) { described_class.(params) }
      subject(:trigger_gift_item!) { described_class.(params1) }

      it 'does trigger state change for gift item' do
        expect(gift_item.state).to eq 'new'

        trigger_gift_item!

        gift_item.reload

        expect(gift_item.state).to eq 'shipment_preparation'
      end

      it 'does not trigger the state for item with blank manufacturer' do
        expect(line_item.state).to eq 'new'

        trigger_empty_manufacturer_item!

        line_item.reload

        expect(line_item.state).to eq 'new'
      end
    end

    context 'items for mass update' do
      let!(:line_item2) { create :line_item, order: order }
      let(:line_item) { create :line_item, order: order, state: :shipped_confirmed }
      let(:event) { :completed }
      let!(:profile) { create :profile, customer: order.customer }
      let!(:billing) { create :billing_order, billable_id: order.id }

      it 'triggers the state and returns items for mass update' do
        expect(line_item.state).to eq 'shipped_confirmed'

        subject

        line_item.reload
        expect(line_item.state).to eq 'completed'
        expect(subject.item).to eq line_item
        expect(subject.items_for_mass_update).to contain_exactly line_item, line_item2
      end
    end

    context 'send to alteration tailor' do
      let(:event) { :back_from_alteration }
      let!(:summary_item) { create :alteration_summary_line_item }
      let!(:summary) { create :alteration_summary, alteration_summary_line_items: [summary_item] }
      let!(:tailor) { create :alteration_tailor }
      let(:line_item) { create :line_item, state: :being_altered, alteration_tailor_id: tailor.id, order: order, manufacturer: 0, alteration_summary_ids: [summary.id] }
      let(:params) { { id: line_item.id, state_event: event, user_id: current_user.id } }

      subject(:back_from_alteration!) { described_class.(params) }

      it 'does trigger state change for gift item' do
        back_from_alteration!

        line_item.reload
        summary.reload
        expect(line_item.state).to eq 'single_at_office'
        expect(summary.state).to eq 'to_be_updated'
      end
    end

    context 'items with ordered and not ordered fabric' do
      let(:event) { :manufacturer_order_created }
      let(:item) { create :line_item, state: :confirmed_profile, order: order, manufacturer: 1, ordered_fabric: true }
      let(:item2) { create :line_item, state: :submitted_profile, order: order, manufacturer: 1, ordered_fabric: false }
      let(:params) { { id: item.id, state_event: event, user_id: current_user.id } }
      let(:params2) { { id: item2.id, state_event: event, user_id: current_user.id } }

      subject(:item_manufacturer_order_created!) { described_class.(params) }
      subject(:item2_manufacturer_order_created!) { described_class.(params2) }

      it 'does trigger state change for item with ordered fabric' do
        expect(item.state).to eq 'confirmed_profile'
        expect(item.ordered_fabric).to be true

        item_manufacturer_order_created!

        item.reload

        expect(item.state).to eq 'fabric_ordered'
      end

      it 'does not trigger the state for item without ordered fabric' do
        expect(item2.state).to eq 'submitted_profile'
        expect(item2.ordered_fabric).to be false

        item2_manufacturer_order_created!

        item2.reload

        expect(item2.state).to eq 'manufacturer_order_created'
      end
    end

    context 'hold item' do
      let(:event) { :hold }
      let(:item) { create :line_item, state: :new, order: order }
      let(:params) { { id: item.id, state_event: event, user_id: current_user.id } }

      subject(:hold!) { described_class.(params) }

      it 'does trigger state change for new item' do
        expect(item.state).to eq 'new'

        hold!

        item.reload

        expect(item.state).to eq 'new_to_be_measured'
      end

      it 'does not trigger for item not in new' do
        item.update_column(:state, 'delivery_email_sent')

        expect(item.state).to eq 'delivery_email_sent'

        hold!

        item.reload

        expect(item.state).to eq 'delivery_email_sent'
      end
    end

    context 'measured item' do
      let(:event) { :measured }
      let(:item) { create :line_item, state: :new_to_be_measured, order: order, remind_to_get_measured: Date.today }
      let(:params) { { id: item.id, state_event: event, user_id: current_user.id } }

      subject(:measured!) { described_class.(params) }

      it 'does trigger state change for new item' do
        expect(item.state).to eq 'new_to_be_measured'
        expect(item.remind_to_get_measured).to eq Date.today

        measured!

        item.reload

        expect(item.state).to eq 'new'
        expect(item.remind_to_get_measured).to be nil
      end

      it 'does not trigger for item not in new_to_be_measured' do
        item.update_column(:state, 'new')

        expect(item.state).to eq 'new'

        measured!

        item.reload

        expect(item.state).to eq 'new'
        expect(item.remind_to_get_measured).to eq Date.today
      end
    end
  end
end
