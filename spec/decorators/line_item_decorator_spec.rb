# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LineItemDecorator, type: :decorator do
  describe '#resolve_item_color_class' do
    let(:occasion_date) { Date.tomorrow }
    let(:item) { create :line_item, occasion_date: occasion_date }
    let(:allowed_time) { 10 } #which makes estimated time Date.today + 10.days

    subject { described_class.decorate(item, context: { timelines: StatesTimeline.all }).resolve_item_color_class }

    context 'late_delivery' do
      context 'when one of dates or all them are missing' do
        it { is_expected.to be_nil }
      end

      context 'when both dates are present' do
        let(:occasion_date) { Date.tomorrow }
        let!(:state_timeline) { create(:states_timeline, state: item.state, from_event: :trigger_manufacturing,
                                                 expected_delivery_time_uk: allowed_time, time_unit: :days) }

        before do
          item.logged_events.create(event: :alteration_requested, from: :trigger_manufacturing, to: item.state, created_at: 5.days.ago)
        end

        context 'when estimated delivery date is less than 10 days from occasion date' do
          let(:occasion_date) { Date.today + (allowed_time + 10).days }

          it { is_expected.to be_nil }
        end

        context 'when estimated delivery date is more than 10 days away' do
          let(:occasion_date) { Date.today }

          it { is_expected.to eq LineItemDecorator::LATE_DELIVERY_STATE }
        end

        context 'when custom_measured is true for the line_item profile' do
          let!(:profile) { create :profile, customer: customer, custom_measured: true }
          let(:customer) { create :customer }
          let(:order) { create :order, customer: customer }
          let(:item) { create :line_item, order: order }

          it { is_expected.to eq 'custom-measured' }
        end

        context 'when custom_measured is false for the line_item profile' do
          let!(:profile) { create :profile, customer: customer, custom_measured: false }
          let(:customer) { create :customer }
          let(:order) { create :order, customer: customer }
          let(:item) { create :line_item, order: order }

          it { is_expected.not_to eq 'custom-measured' }
        end
      end
    end
  end

  describe '#shipped_fit_not_confirmed_button' do
    let(:customer) { create :customer }
    let(:profile) { create :profile, customer: customer }
    let(:order) { create :order, customer: customer }

    subject { described_class.decorate(item).send(:shipped_fit_not_confirmed_button) }

    context 'with valid measurement status' do
      let(:product) { create :product, category: 'MADE-TO-MEASURE SUITS' }
      let(:item) { create :line_item, state: :delivery_arranged, product: product, order: order }
      let(:pants_category) { create :category, name: 'Pants' }
      let(:jacket_category) { create :category, name: 'Jackets' }
      let!(:pants_profile_category) { create :profile_category, profile: profile, category: pants_category, status: 'submitted' }
      let!(:jacket_profile_category) { create :profile_category, profile: profile, category: jacket_category, status: 'confirmed' }

      it 'shows button' do
        expect(subject).to be
      end
    end

    context 'with Confirmed measurement status' do
      let(:product) { create :product, category: 'MADE-TO-MEASURE CHINOS' }
      let(:item) { create :line_item, state: :delivery_arranged, product: product, order: order }
      let(:chinos_category) { create :category, name: 'Chinos' }
      let!(:chinos_profile_category) { create :profile_category, profile: profile, category: chinos_category, status: 'confirmed' }

      it 'does not show button' do
        expect(subject).to be_nil
      end
    end
  end

  describe '#date_entered_state' do
    let(:item) { build :line_item, state_entered_date: Date.today, created_at: Date.yesterday }

    subject { described_class.decorate(item).date_entered_state }

    it { is_expected.to eq I18n.l(Date.today, format: :order_date) }

    context 'when state_entered_date is nil' do
      let(:item) { build :line_item, state_entered_date: nil, created_at: Date.yesterday }

      it { is_expected.to eq I18n.l(Date.yesterday, format: :order_date) }
    end
  end

  describe '#customer_type' do
    let(:customer) { create :customer }
    let(:order) { create :order, customer: customer }
    let(:item) { create :line_item, order: order }

    subject { described_class.decorate(item).customer_type }

    context 'when it is the first order' do
      let(:order) { create :order, first_order: true }

      it { is_expected.to eq 'New' }
    end

    context 'when it is not the first order' do
      let(:order) { create :order, first_order: false }

      it { is_expected.to eq 'Repeat' }
    end
  end

  describe '#alteration_costs' do
    let(:summary) { create :alteration_summary, amount: 10 }
    let(:summary1) { create :alteration_summary, amount: 20 }
    let(:summary2) { create :alteration_summary, amount: 30 }
    let(:item) { create :line_item, alteration_summaries: [summary, summary1, summary2] }

    subject { described_class.decorate(item).alteration_costs }

    it 'returns alteration costs for item' do
      expect(subject).to be_a BigDecimal
      expect(subject).to eq 60
    end
  end

  describe '#meters_required_field' do
    let!(:product) { create :product, category: 'MADE-TO-MEASURE SUITS' }
    let!(:item) { create :line_item, product: product }

    subject { described_class.decorate(item).meters_required_field }

    it 'returns required meters number' do
      expect(subject).to eq 3.5
    end
  end

  describe '#warning_extra_fabric' do
    let!(:profile) { create :profile }
    let!(:category) { create :category}
    let!(:param) { create :param, title: 'Chest' }
    let!(:category_param) { create :category_param, category_id: category.id, param_id: param.id}
    let!(:measurement) { create :measurement, final_garment: 55, profile_id: profile.id, category_param_id: category_param.id }
    let!(:customer) { create :customer, profile: profile }
    let!(:order) { create :order, customer: customer }
    let!(:item) { create :line_item, order: order }

    subject { described_class.decorate(item).warning_extra_fabric }

    it 'returns YES if extra fabric needed' do
      expect(subject).to eq 'YES'
    end

    it 'returns NO if there is no need in extra fabric' do
      measurement.destroy

      expect(subject).to eq 'NO'
    end
  end

  describe '#m_order_number_not_made' do
    let!(:product) { create :product, category: 'MADE-TO-MEASURE SUITS' }
    let!(:customer) { create :customer }
    let!(:order) { create :order, customer: customer }
    let!(:location) { create :sales_location, name: 'City Showroom' }
    let!(:item) { create :line_item, order_id: order.id, product: product, sales_location: location }
    let!(:item2) { create :line_item, m_order_number: nil, order_id: order.id, product: product, sales_location: location }

    subject { described_class.decorate(item2).m_order_number_not_made }

    context 'for item without m_order_number' do
      it 'builds m_order_number' do
        expect(subject).to eq "ESCTY_#{order.id}_SU_2"
      end
    end

    context 'for item with m_order_number' do
      subject { described_class.decorate(item).m_order_number_not_made }

      it 'returns nil' do
        expect(subject).to be nil
      end
    end
  end

  describe '#maybe_special_customizations' do
    subject { described_class.decorate(item).maybe_special_customizations }

    context 'item with special customizations' do
      let!(:item) { create :line_item, meta: [{ 'label' => 'Pant Front', 'key' => 'Pant Front', 'value' => 'One Pleat' }] }

      it 'returns corresponding label for the item' do
        expect(subject).to eq ['Pleat']
      end
    end

    context 'item without special customizations' do
      let!(:item) { create :line_item, meta: [{ 'label' => 'Pant Front', 'key' => 'Pant Front', 'value' => 'No Pleat' }] }

      it 'returns empty label for the item' do
        expect(subject).to be_empty
      end
    end
  end

  describe '#maybe_days_in_state_field' do
    subject { described_class.decorate(item).maybe_days_in_state_field }

    context 'item with present date_entered_state' do
      let!(:item) { create :line_item, state: 'new', state_entered_date: 1.day.ago }

      it 'shows how long line_item has been in that state' do
        expect(subject).to eq '1 day'
      end
    end

    context 'item without date_entered_state' do
      let!(:item) { create :line_item, state: 'new', state_entered_date: nil }

      it 'returns empty value' do
        expect(subject).to be_nil
      end
    end
  end

  describe '#fabric_code' do
    let!(:item) { create :line_item, meta: [{ 'label' => 'Fabric Code', 'key' => 'Fabric Code', 'value' => 'BD911' }] }

    subject { described_class.decorate(item).fabric_code }

    it 'returns selector field' do
      expect(subject).to match '<span class=\"far fa-edit\" aria-hidden=\"true\"'
    end
  end
end
