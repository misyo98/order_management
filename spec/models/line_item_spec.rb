# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LineItem, type: :model do
  describe '#trigger_waiting_items' do
    let(:order) { create :order }
    let(:product) { create :product, category: 'MADE-TO-MEASURE SHIRTS' }
    let(:line_item) { create :line_item, state: :waiting_for_confirmation, product: product }
    let(:line_item1) { create :line_item, state: :new, product: product }

    before { order.line_items << [line_item, line_item1] }

    it 'changes items with state :waiting_for_confirmation to :fit_confirmed' do
      line_item.trigger_waiting_items
      line_item.reload
      expect(line_item.state).to eq 'fit_confirmed'
    end

    it 'does not change the items with different states' do
      line_item.trigger_waiting_items
      line_item1.reload
      expect(line_item1.state).to eq 'new'
    end
  end

  describe '#local_category' do
    let(:product_shirt) { create :product, category: 'MADE-TO-MEASURE SHIRTS' }
    let(:product_suits) { create :product, category: 'MADE-TO-MEASURE SUITS' }
    let(:product_gift) { create :product, category: 'GIFT' }
    let(:shirt_item) { create :line_item, product: product_shirt }
    let(:suits_item) { create :line_item, product: product_suits }
    let(:gift_item) { create :line_item, product: product_gift }
    let(:no_product_item) { create :line_item, product: nil }

    context 'simple category like Shirt, Chinos, Waistcoat...' do
      subject { shirt_item.local_category }

      it { is_expected.to contain_exactly 'Shirt' }
    end

    context 'complex category - Suits' do
      subject { suits_item.local_category }

      it { is_expected.to contain_exactly 'Jacket', 'Pants'  }
    end

    context 'no category' do
      subject { no_product_item.local_category }

      it { is_expected.to contain_exactly 'n/a'  }
    end

    context 'other product category' do
      subject { gift_item.local_category }

      it { is_expected.to contain_exactly 'n/a'  }
    end
  end

  describe '#ship_items' do
    let(:product_gift) { create :product, category: 'GIFT CARD' }
    let(:product_shirt) { create :product, category: 'MADE-TO-MEASURE SHIRT' }
    let(:gift_item) { create :line_item, product: product_gift, state: :shipment_preparation }
    let(:shirt_item) { create :line_item, product: product_shirt, state: :new }

    context 'item with gift product category' do
      subject(:ship_items!) { gift_item.ship_items }

      it 'changes state to shipped_confirmed' do
        ship_items!

        expect(gift_item.gift_category?).to be true
        expect(gift_item.state).to eq 'shipped_confirmed'
      end
    end

    context 'item with non-gift product category' do
      subject(:ship_items!) { shirt_item.ship_items }

      it 'cannot make transition to shipped_confirmed for non-gift item' do
        ship_items!

        expect(shirt_item.gift_category?).to be false
        expect(shirt_item.state).to eq 'new'
      end
    end
  end

  describe '#confirm_profile_category_fit' do
    let(:customer) { create :customer }
    let(:profile) { create :profile, customer: customer }
    let(:order) { create :order, customer: customer }
    let(:shirt_category) { create :category, name: 'Shirt' }
    let(:jacket_category) { create :category, name: 'Jacket' }
    let(:pants_category) { create :category, name: 'Pants' }
    let(:product_shirt) { create :product, category: 'MADE-TO-MEASURE SHIRTS' }
    let(:product_jacket) { create :product, category: 'MADE-TO-MEASURE JACKETS' }
    let(:product_suits) { create :product, category: 'MADE-TO-MEASURE SUITS' }
    let!(:shirt_item) { create :line_item, product: product_shirt, order: order }
    let!(:jacket_item) { create :line_item, product: product_jacket, order: order }
    let!(:suits_item) { create :line_item, product: product_suits, order: order }
    let!(:profile_category_shirt) { create :profile_category, profile: profile, category: shirt_category, status: :to_be_submitted }
    let!(:profile_category_jacket) { create :profile_category, profile: profile, category: jacket_category, status: :to_be_submitted }
    let!(:profile_category_pants) { create :profile_category, profile: profile, category: pants_category, status: :to_be_submitted }

    context 'simple category like Shirt, Chinos, Waistcoat...' do
      subject { shirt_item.confirm_profile_category_fit }

      it 'triggers confirmed_fit for proper profile category' do
        expect(profile_category_shirt.status).to eq 'to_be_submitted'

        subject

        profile_category_shirt.reload

        expect(profile_category_shirt.status).to eq 'confirmed'
      end
    end

    context 'complex category - Suits' do
      subject { suits_item.confirm_profile_category_fit }

      it 'triggers confirmed_fit for proper profile categories' do
        expect(profile_category_jacket.status).to eq 'to_be_submitted'
        expect(profile_category_pants.status).to eq 'to_be_submitted'

        subject

        [profile_category_jacket, profile_category_pants].each(&:reload)

        expect(profile_category_jacket.status).to eq 'confirmed'
        expect(profile_category_pants.status).to eq 'confirmed'
      end
    end
  end

  describe '#trigger_waiting_items' do
    let(:order) { create :order }
    let(:product_pants) { create :product, category: 'MADE-TO-MEASURE TROUSERS' }
    let(:product_jacket) { create :product, category: 'MADE-TO-MEASURE JACKETS' }
    let(:product_suits) { create :product, category: 'MADE-TO-MEASURE SUITS' }
    let!(:pants_item) { create :line_item, product: product_pants, order: order, state: :waiting_for_confirmation }
    let!(:pants_item2) { create :line_item, product: product_pants, order: order, state: :waiting_for_confirmation }
    let!(:jacket_item) { create :line_item, product: product_jacket, order: order, state: :waiting_for_confirmation }
    let!(:suits_item) { create :line_item, product: product_suits, order: order, state: :waiting_for_confirmation }

    context 'simple category like Shirt, Chinos, Pants...' do
      subject { pants_item.trigger_waiting_items }

      it 'changes proper items states to fit_confirmed' do
        expect(pants_item.state).to eq 'waiting_for_confirmation'
        expect(pants_item2.state).to eq 'waiting_for_confirmation'

        subject

        [pants_item, pants_item2].each(&:reload)

        expect(pants_item.state).to eq 'fit_confirmed'
        expect(pants_item2.state).to eq 'fit_confirmed'
      end
    end

    context 'complex category - Suits' do
      subject { [pants_item, jacket_item].sample.trigger_waiting_items }

      it 'changes proper items states to fit_confirmed' do
        expect(suits_item.state).to eq 'waiting_for_confirmation'

        subject

        suits_item.reload

        expect(suits_item.state).to eq 'fit_confirmed'
      end
    end
  end

  describe '#is_delayed?' do
    let(:order) { create(:order, created_at: 5.days.ago) }
    let(:item) { create(:line_item, state: :fabric_received, order: order) }
    let(:altered_item) { create(:line_item, state: :alteration_requested, order: order) }

    context 'when from_event is an actual state machine event' do
      before do
        item.logged_events.create(event: :trigger_manufacturing, from: :new, to: :fabric_received, created_at: 4.days.ago)
      end

      subject { item.is_delayed? }

      it 'should be delayed if event happened later than allowed' do
        allowed_time = 2
        create(:states_timeline, state: item.state,
               from_event: :trigger_manufacturing,
               allowed_time_uk: allowed_time, time_unit: :days)

        expect(subject).to be true
      end

      it 'should not be delayed if event happened within allowed time' do
        allowed_time = 4
        create(:states_timeline, state: item.state,
               from_event: :trigger_manufacturing,
               allowed_time_uk: allowed_time, time_unit: :days)

        expect(subject).to be false
      end

      context 'it takes the last timeline to make a comparsion' do
        before do
          altered_item.logged_events.create(event: :alteration_requested, from: :new, to: :fabric_received, created_at: 3.days.ago)
          altered_item.logged_events.create(event: :alteration_requested, from: :new, to: :fabric_received, created_at: 5.days.ago)
        end

        subject { altered_item.is_delayed? }

        it do
          allowed_time = 3
          create(:states_timeline, state: altered_item.state,
                 from_event: :alteration_requested,
                 allowed_time_uk: allowed_time, time_unit: :days)

          expect(subject).to be false
        end

        it do
          allowed_time = 1
          create(:states_timeline, state: altered_item.state,
                 from_event: :alteration_requested,
                 allowed_time_uk: allowed_time, time_unit: :days)

          expect(subject).to be true
        end
      end
    end

    context 'when from_event is order_date' do

      subject { item.is_delayed? }

      it 'should be delayed if event happened later than allowed' do
        allowed_time = 2
        create(:states_timeline, state: item.state,
               from_event: :order_date,
               allowed_time_uk: allowed_time, time_unit: :days)

        expect(subject).to be true
      end

      it 'should not be delayed if event happened within allowed time' do
        allowed_time = 5
        create(:states_timeline, state: item.state,
               from_event: :order_date,
               allowed_time_uk: allowed_time, time_unit: :days)

        expect(subject).to be false
      end
    end

    context 'edge cases' do
      context 'with no timeline' do
        subject { item.is_delayed? }

        it { is_expected.to be false }
      end

      context 'with no corresponding state event' do
        subject { item.is_delayed? }

        it do
          allowed_time = 5
          create(:states_timeline, state: item.state,
                 from_event: :order_date,
                 allowed_time_uk: allowed_time, time_unit: :days)

          expect(subject).to be false
        end
      end

      context 'with no allowed_time' do
        subject { item.is_delayed? }

        it do
          allowed_time = nil
          create(:states_timeline, state: item.state, from_event: :order_date,
                 allowed_time_uk: allowed_time, time_unit: :days)

          expect(subject).to be true
        end
      end
    end
  end

  describe '#measurement_category_statuses related methods' do
    let(:customer) { create :customer }
    let(:profile) { create :profile, customer: customer }
    let(:order) { create :order, customer: customer }
    let(:shirt_category) { create :category, name: 'Shirt' }
    let(:pants_category) { create :category, name: 'Pants' }
    let(:product_shirt) { create :product, category: 'MADE-TO-MEASURE SHIRTS' }
    let(:product_pants) { create :product, category: 'MADE-TO-MEASURE TROUSERS' }
    let!(:shirt_profile_category) { create :profile_category, profile: profile, category: shirt_category, status: :submitted }
    let(:shirt_line_item) { create :line_item, order: order, product: product_shirt }
    let(:pants_line_item) { create :line_item, order: order, product: product_pants }

    describe '#no_measurement_profile?' do
      context 'when no measurements for item category exists in profile' do
        subject { pants_line_item.no_measurement_profile? }

        it { is_expected.to be true }
      end

      context 'when measurements for item category do exists in profile' do
        subject { shirt_line_item.no_measurement_profile? }

        it { is_expected.to be false }
      end

      context 'for suits case' do
        let(:product_suits) { create :product, category: 'MADE-TO-MEASURE SUITS' }
        let(:jacket_category) { create :category, name: 'Jacket' }
        let!(:jacket_profile_category) { create :profile_category, profile: profile, category: jacket_category }
        let(:suits_line_item) { create :line_item, order: order, product: product_suits }

        context 'when only one of two categories exists' do
          subject { suits_line_item.no_measurement_profile? }

          it { is_expected.to be true }
        end
      end
    end

    describe '#measurement_profile_to_be_fixed?' do
      subject { shirt_line_item.measurement_profile_to_be_fixed? }

      context 'when measurements for item category in profile are to_be_fixed' do
        before { shirt_profile_category.update_column(:status, ProfileCategory.statuses[:to_be_fixed]) }

        it { is_expected.to be true }
      end

      context 'when measurements for item category in profile are submitted' do
        it { is_expected.to be false }
      end

      context 'when measurements for item category in profile are confirmed' do
        before { shirt_profile_category.update_column(:status, ProfileCategory.statuses[:confirmed]) }

        it { is_expected.to be false }
      end

      context 'for suits case' do
        let(:product_suits) { create :product, category: 'MADE-TO-MEASURE SUITS' }
        let(:jacket_category) { create :category, name: 'Jacket' }
        let!(:jacket_profile_category) { create :profile_category, profile: profile, category: jacket_category, status: :submitted }
        let!(:pants_profile_category) { create :profile_category, profile: profile, category: pants_category, status: :to_be_fixed }
        let(:suits_line_item) { create :line_item, order: order, product: product_suits }

        context 'when one of the categories is in to_be_fixed state' do
          subject { suits_line_item.measurement_profile_to_be_fixed? }

          it { is_expected.to be true }
        end

        context 'when none of the categories are to_be_fixed' do
          subject { suits_line_item.measurement_profile_to_be_fixed? }

          before { pants_profile_category.update_column(:status, ProfileCategory.statuses[:submitted]) }

          it { is_expected.to be false }
        end
      end
    end

    describe '#measurement_profile_unconfirmed?' do
      subject { shirt_line_item.measurement_profile_unconfirmed? }

      context 'when measurements for item category in profile are unconfirmed' do
        it { is_expected.to be true }
      end

      context 'when measurements for item category in profile are confirmed' do
        before { shirt_profile_category.update_column(:status, ProfileCategory.statuses[:confirmed]) }

        it { is_expected.to be false }
      end
    end
  end

  describe 'scopes' do
    describe '.for_customer' do
      let(:customer) { create :customer }
      let(:order) { create :order, customer: customer }
      let(:line_item) { create :line_item, order: order }
      let(:line_item2) { create :line_item, order: order }
      let(:line_item3) { create :line_item }

      subject { described_class.for_customer(customer.id) }

      it { is_expected.to contain_exactly line_item, line_item2 }
    end

    describe '.with_categories' do
      let(:product_shirt) { create :product, category: 'MADE-TO-MEASURE SHIRTS' }
      let(:product_chinos) { create :product, category: 'MADE-TO-MEASURE CHINOS' }
      let(:product_pants) { create :product, category: 'MADE-TO-MEASURE TROUSERS' }
      let(:product_jacket) { create :product, category: 'MADE-TO-MEASURE JACKETS' }
      let(:product_suits) { create :product, category: 'MADE-TO-MEASURE SUITS' }
      let!(:shirt_item) { create :line_item, product: product_shirt }
      let!(:chinos_item) { create :line_item, product: product_chinos }
      let!(:pants_item) { create :line_item, product: product_pants }
      let!(:jacket_item) { create :line_item, product: product_jacket }
      let!(:suits_item) { create :line_item, product: product_suits }
      let(:categories) { ['Shirt', 'Pants'] }

      subject { described_class.with_categories(categories) }

      it { is_expected.to contain_exactly shirt_item, pants_item, suits_item }

      context 'SUITS category' do
        let(:categories) { ['Jacket', 'Pants'] }

        it { is_expected.to contain_exactly suits_item, jacket_item, pants_item }
      end
    end
  end

  describe 'changing item state to delivery_email_sent or shipment_preparation callback' do
    let(:order) { create :order }
    let!(:item1) { create :line_item, order: order, state: 'waiting_for_items_alteration' }
    let!(:item2) { create :line_item, order: order, state: 'last_at_office' }
    let!(:item3) { create :line_item, order: order, state: 'new' }

    subject { item2.prepare_shipment! }

    it 'works' do
      expect { subject }.to change { Sidekiq::Worker.jobs.size }.by 0

      [item1, item2, item3].each(&:reload)

      expect(item1.state).to eq 'shipment_preparation'
      expect(item2.state).to eq 'shipment_preparation'
      expect(item3.state).to eq 'new'
    end

    context 'changing state to delivery_email_sent' do
      subject { item2.send_delivery_appt_email! }

      it 'works' do
        expect { subject }.to change { Sidekiq::Worker.jobs.size }.by 1

        [item1, item2, item3].each(&:reload)

        expect(item1.state).to eq 'delivery_email_sent'
        expect(item2.state).to eq 'delivery_email_sent'
        expect(item3.state).to eq 'new'
      end
    end

    context 'gift_item' do
      let!(:product) { create :product, category: 'NON-CUSTOM' }
      let!(:gift_item) { create :line_item, order: order, state: 'new', product: product }

      subject { gift_item.prepare_shipment! }

      it 'changes state to shipment_preparation' do
        expect(gift_item.state).to eq 'new'
        expect { subject }.to change { Sidekiq::Worker.jobs.size }.by 0

        gift_item.reload

        expect(gift_item.state).to eq 'shipment_preparation'
      end
    end
  end


  describe 'check if user can send delivery emails' do
    let(:order) { create :order }
    let(:item) { create :line_item, order: order, state: 'delivery_arranged' }
    let(:user) { create :user, can_send_delivery_emails: true }

    subject { item.back_to_delivery_email_sent!(user_id: user.id) }

    context 'user can send email' do
      it 'sends' do
        expect { subject }.to change(EmailsQueue, :count).by 1
      end
    end

    context 'user cannot send email' do
      let(:user) { create :user, can_send_delivery_emails: false }

      it 'does not send' do
        expect { subject }.to change(EmailsQueue, :count).by 0
      end
    end

    context 'there is no user' do
      subject { item.back_to_delivery_email_sent!(user_id: nil) }

      it 'sends' do
        expect { subject }.to change(EmailsQueue, :count).by 1
      end
    end
  end

  describe 'assign tags to line item' do
    let(:order) { create :order }
    let(:item) { create :line_item, order: order, state: 'new', tag_ids: [tag.id, tag1.id] }
    let(:tag) { create :tag, name: 'First' }
    let(:tag1) { create :tag, name: 'Second' }
    let(:item_tag) { create :line_item_tag, tag: tag, line_item: item }

    context 'line item tags' do
      it 'contains exact tags' do
        expect(item.tags).to contain_exactly tag, tag1
      end
    end
  end

  describe '#wait_for_other_items' do
    let(:jacket_product) { create :product, category: 'MADE-TO-MEASURE JACKETS' }
    let(:gift_product) { create :product, category: 'GIFT CARD' }
    let(:jacket_item) { create :line_item, state: :new, product: jacket_product }
    let(:gift_item) { create :line_item, state: :new, product: gift_product }

    context 'gift item with state new' do
      subject(:wait_for_other_items!) { gift_item.wait_for_other_items }

      it 'changes state for gift_item to waiting_for_items' do
        expect(gift_item.state).to eq 'new'

        wait_for_other_items!

        gift_item.reload

        expect(gift_item.state).to eq 'waiting_for_items'
      end
    end

    context 'non-gift item with state new' do
      subject(:wait_for_other_items!) { jacket_item.wait_for_other_items }

      it 'changes state for gift_item to waiting_for_items' do
        expect(jacket_item.state).to eq 'new'

        wait_for_other_items!

        jacket_item.reload

        expect(jacket_item.state).to eq 'new'
      end
    end

    context 'non-gift item with state partial_at_office' do
      let(:jacket_item) { create :line_item, state: :partial_at_office, product: jacket_product }

      subject(:wait_for_other_items!) { jacket_item.wait_for_other_items }

      it 'changes state for gift_item to waiting_for_items' do
        expect(jacket_item.state).to eq 'partial_at_office'

        wait_for_other_items!

        jacket_item.reload

        expect(jacket_item.state).to eq 'waiting_for_items'
      end
    end
  end

  describe '#paid_or_create_date_lteq' do
    let(:order) { create :order, created_at: Date.current - 2.weeks, paid_date: Date.current - 10.days }
    let!(:item_1) { create :line_item, state: :new, order: order }
    let!(:item_2) { create :line_item, state: :new, order: order }

    context 'aiming for paid_date' do
      subject(:search_result) { described_class.paid_or_create_date_lteq(Date.current - 1.week) }

      it 'returns searched items' do
        expect(search_result).to contain_exactly item_1, item_2
      end
    end

    context 'aiming for created_at' do
      subject(:search_result) { described_class.paid_or_create_date_lteq(Date.current - 2.weeks) }

      it 'returns searched items' do
        expect(search_result).to contain_exactly item_1, item_2
      end
    end

    context 'aiming far then both paid and created_at dates' do
      subject(:search_result) { described_class.paid_or_create_date_lteq(Date.current - 3.weeks) }

      it 'finds no matching items' do
        expect(search_result).to eq []
      end
    end

    context 'order has no paid_date' do
      subject(:search_result) { described_class.paid_or_create_date_lteq(Date.current) }

      it 'returns items based on created_at date' do
        order.update(paid_date: nil)

        expect(order.paid_date).to be nil
        expect(search_result).to contain_exactly item_1, item_2
      end
    end
  end

  describe '#paid_or_create_date_gteq' do
    let(:order) { create :order, created_at: Date.current - 10.days, paid_date: Date.current - 1.week }
    let!(:item_1) { create :line_item, state: :new, order: order }
    let!(:item_2) { create :line_item, state: :new, order: order }

    context 'aiming for paid_date' do
      subject(:search_result) { described_class.paid_or_create_date_gteq(Date.current - 1.week) }

      it 'returns searched items' do
        expect(search_result).to contain_exactly item_1, item_2
      end
    end

    context 'aiming for created_at' do
      subject(:search_result) { described_class.paid_or_create_date_gteq(Date.current - 2.weeks) }

      it 'returns searched items' do
        expect(search_result).to contain_exactly item_1, item_2
      end
    end

    context 'aiming far then both paid and created_at dates' do
      subject(:search_result) { described_class.paid_or_create_date_gteq(Date.current - 5.days) }

      it 'finds no matching items' do
        expect(search_result).to eq []
      end
    end

    context 'order has no paid_date' do
      subject(:search_result) { described_class.paid_or_create_date_gteq(Date.current - 2.weeks) }

      it 'returns items based on created_at date' do
        order.update(paid_date: nil)

        expect(order.paid_date).to be nil
        expect(search_result).to contain_exactly item_1, item_2
      end
    end
  end
end
