# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LineItemStateTransition, type: :model do
  describe '.last_event' do
    let!(:transition) { create :line_item_state_transition, event: :alteration_requested, 
                                                            from: :new, to: :fabric_received, 
                                                            created_at: 3.days.ago }

    subject { described_class.last_event(event) }

    context 'with valid event' do
      let(:event) { :alteration_requested }

      context 'with one similar transition' do
        it { is_expected.to eq transition }
      end

      context 'with a few similar transitions' do
        let!(:transition2) { create :line_item_state_transition, event: :alteration_requested, 
                                                                 from: :new, to: :fabric_received, 
                                                                 created_at: 2.days.ago }

        it 'choses the latest transition' do
          expect(subject).to eq transition2
        end
      end
    end

    context 'with invalid event' do
      let(:event) { :invalid_event }

      it { is_expected.to be nil }
    end
  end

  describe '.last_entered_state' do
    let!(:transition) { create :line_item_state_transition, event: :alteration_requested, 
                                                            from: :new, to: :fabric_received, 
                                                            created_at: 3.days.ago }

    subject { described_class.last_entered_state(state) }

    context 'with valid state' do
      let(:state) { :fabric_received }

      context 'with one similar transition' do
        it { is_expected.to eq transition }
      end

      context 'with a few similar transitions' do
        let!(:transition2) { create :line_item_state_transition, event: :alteration_requested, 
                                                                 from: :new, to: :fabric_received, 
                                                                 created_at: 2.days.ago }

        it 'choses the latest transition' do
          expect(subject).to eq transition2
        end
      end
    end

    context 'with invalid state' do
      let(:state) { :invalid_state }

      it { is_expected.to be nil }
    end
  end

  describe 'callbacks' do
    describe 'after_create' do
      describe '#update_item_entered_state_date' do
        let(:line_item) { create :line_item, state: 'new', state_entered_date: nil }

        subject { line_item.wait! }

        it 'creates logged event and updates state_entered_date' do
          expect { subject }.to change { line_item.logged_events.count }.by 1

          line_item.reload

          expect(line_item.state).to eq 'waiting_for_confirmation'
          expect(line_item.state_entered_date.to_date).to eq Date.today
        end

        context 'when event is not from state events list' do
          let(:line_item) { create :line_item, state: 'new', state_entered_date: nil }

          subject { line_item.logged_events.create(event: :comment_added, comment_body: 'Body') }

          it 'creates event but not updates state_entered_date' do
            expect { subject }.to change { line_item.logged_events.count }.by 1

            line_item.reload

            expect(line_item.state).to eq 'new'
            expect(line_item.state_entered_date).to be_nil
          end
        end
      end
    end
  end
end
