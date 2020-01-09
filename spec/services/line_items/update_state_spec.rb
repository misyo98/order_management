# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LineItems::UpdateState do
  let(:test_instance) { Class.new { include LineItems::UpdateState }.new }

  describe 'update_shipped_confirmed' do
    let(:customer) { create :customer }
    let!(:profile) { create :profile, customer: customer }
    let(:order) { create :order, customer: customer }
    let!(:billing) { create :billing, billable_id: order.id, billable_type: 'Order' }
    let(:courier) { create :courier_company }

    before do
      allow_any_instance_of(Asknicely::API).to receive(:send_survey).and_return({'success' => true})
    end

    subject { test_instance.update_shipped_confirmed }

    context 'line item after 5 days' do
      describe 'with valid logged events' do
        let(:item) do create :line_item,
          order: order,
          courier: courier,
          outbound_tracking_number: 123,
          state: 'shipped_confirmed'
        end
        let!(:event_1) do create :line_item_state_transition,
          line_item: item,
          from: 'shipped_waiting_confirmation',
          to: 'shipped_confirmed',
          created_at: 6.days.ago
        end
        let!(:event_2) do create :line_item_state_transition,
          line_item: item,
          from: 'shipped_waiting_confirmation',
          to: 'shipped_confirmed',
          created_at: 3.days.ago
        end

        it 'changes state to completed' do
          expect(subject).to eq [true]
          item.reload
          expect(item.state).to eq 'completed'
          expect(item.logged_events.pluck(:to)).to include 'completed'
        end
      end

      describe 'with invalid logged events' do
        let(:item) do create :line_item,
          order: order,
          courier: courier,
          outbound_tracking_number: 123,
          state: 'shipped_confirmed'
        end
        let!(:event) do create :line_item_state_transition,
          line_item: item,
          to: 'new',
          created_at: Time.now
        end

        it 'does not change state' do
          expect(subject).to eq []
          item.reload
          expect(item.state).to eq 'shipped_confirmed'
          expect(item.logged_events.pluck(:to)).not_to include 'completed'
        end
      end
    end
  end

end
