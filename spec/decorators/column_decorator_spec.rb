# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ColumnDecorator, type: :decorator do
  describe '#sortable_state' do
    let(:column) { build :column, name: :date_entered_state }

    subject { described_class.decorate(column).sortable_state }

    it { is_expected.to eq :state_entered_date }

    context 'when column name not in sortable list' do
      let(:column) { build :column, name: :shipping_address_1 }

      it { is_expected.to be false }
    end
  end

  describe '#not_for_outfitters?' do
    let(:user) { create :user, role: :outfitter }
    let(:column) { build :column, name: :email }

    subject { described_class.decorate(column).not_for_outfitters?(user) }

    it { is_expected.to be true }

    context 'when user not outfitter' do
      let(:user) { create :user, role: :admin }

      it { is_expected.to be false }
    end

    context 'when column not forbidden for outfitter' do
      let(:column) { build :column, name: :shipping_city }

      it { is_expected.to be false }
    end
  end
end
