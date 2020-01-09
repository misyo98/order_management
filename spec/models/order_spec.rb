# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'callbacks' do
    describe '#check_if_first_order' do
      let(:order) { build(:order, customer: customer) }

      before { order.class.set_callback(:create, :before, :check_if_first_order) }

      subject(:create!) { order.save }

      context 'when no customer' do
        let(:customer) { nil }

        it 'is false' do
          create!
          order.reload
          expect(order.first_order).to be false
        end
      end

      context 'when customer exists' do
        let(:customer) { create(:customer) }

        it 'is true' do
          create!
          order.reload
          expect(order.first_order).to be true
        end
      end

      context 'when customer exists but his previous order was cancelled' do
        let(:customer) { create :customer }
        let!(:order) { build :order, customer: customer, status: Order.statuses[:pending] }
        let!(:order2) { create :order, customer: customer, status: Order.statuses[:cancelled] }

        before { order.class.set_callback(:create, :before, :check_if_first_order) }

        it 'set first_order to true' do
          create!

          order.reload
          customer.reload

          expect(order.first_order?).to be true
        end
      end
    end
  end
end
