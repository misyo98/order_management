# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmailsQueues::CreateDeliveryEmail do
  let!(:category1) { create :category, name: 'Shirt' }
  let!(:category2) { create :category, name: 'Pants' }
  let!(:customer) { create :customer, first_name: 'Jack' }
  let!(:profile) { create :profile, customer: customer }
  let!(:order) { create :order, customer: customer }
  let!(:product1) { create :product, category: 'MADE-TO-MEASURE SHIRTS' }
  let!(:product2) { create :product, category: 'MADE-TO-MEASURE TROUSERS' }
  let!(:item1) { create :line_item, order: order, state: :partial_at_office, product: product1 }
  let!(:item2) { create :line_item, order: order, state: :single_at_office, product: product2 }

  describe '.call' do
    it 'creates an email' do
      expect { described_class.(item1) }.to change(EmailsQueue, :count).by 1
    end

    context 'delivery email layout for confirmed_condition' do
      let!(:profile_category1) { create :profile_category, profile: profile, category: category1, status: :confirmed }
      let!(:profile_category2) { create :profile_category, profile: profile, category: category2, status: :confirmed }

      subject(:create_email) { described_class.(item1) }

      it 'creates delivery email with courier_button template for confirmed profile' do
        expect(profile_category1.status).to eq 'confirmed'

        expect { create_email }.to change(EmailsQueue, :count).by 1

        email = EmailsQueue.last

        expect(email.delivery_email_layout).to eq 'with_courier_button'
      end

      it 'creates delivery email with regular template for non-confirmed profile' do
        profile_category2.update_column(:status, ProfileCategory.statuses[:submitted])

        expect(profile_category2.status).to eq 'submitted'

        expect { create_email }.to change(EmailsQueue, :count).by 1

        email = EmailsQueue.last

        expect(email.delivery_email_layout).to eq 'regular'
      end

      it 'create delivery email with regular template for items not in state' do
        item1.update_column(:state, 'new')
        item2.update_column(:state, 'new')

        expect(item1.state).to eq 'new'
        expect(item2.state).to eq 'new'

        expect { create_email }.to change(EmailsQueue, :count).by 1

        email = EmailsQueue.last

        expect(email.delivery_email_layout).to eq 'regular'
      end
    end

    context 'delivery email layout for submitted_condition' do
      let!(:profile_category1) { create :profile_category, profile: profile, category: category1, status: :submitted }
      let!(:profile_category2) { create :profile_category, profile: profile, category: category2, status: :submitted }
      let!(:state_transition1) { create :line_item_state_transition, line_item: item1, from: 'being_altered' }
      let!(:state_transition2) { create :line_item_state_transition, line_item: item2, from: 'being_altered' }

      subject(:create_email) { described_class.(item2) }

      it 'creates delivery email with courier_button template for submitted profile' do
        expect(profile_category1.status).to eq 'submitted'
        expect(profile_category2.status).to eq 'submitted'

        expect { create_email }.to change(EmailsQueue, :count).by 1

        email = EmailsQueue.last

        expect(email.delivery_email_layout).to eq 'with_courier_button'
      end

      it 'creates delivery email with regular template for non-altered item' do
        expect(profile_category2.status).to eq 'submitted'

        state_transition2.destroy

        expect { create_email }.to change(EmailsQueue, :count).by 1

        email = EmailsQueue.last

        expect(email.delivery_email_layout).to eq 'regular'
      end
    end

    context 'delivery email layout with_courier_button for confirmed_and_submitted_condition' do
      let!(:profile_category1) { create :profile_category, profile: profile, category: category1, status: :confirmed }
      let!(:profile_category2) { create :profile_category, profile: profile, category: category2, status: :submitted }
      let!(:state_transition2) { create :line_item_state_transition, line_item: item2, from: 'being_altered' }

      subject(:create_email) { described_class.(item2) }

      it 'creates delivery email with courier_button template for profile with confirmed and submitted categories' do
        expect(profile_category1.status).to eq 'confirmed'
        expect(profile_category2.status).to eq 'submitted'

        expect { create_email }.to change(EmailsQueue, :count).by 1

        email = EmailsQueue.last

        expect(email.delivery_email_layout).to eq 'with_courier_button'
      end
    end
  end
end
