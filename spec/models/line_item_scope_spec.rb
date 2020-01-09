# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LineItemScope, type: :model do
  describe '#visible_for_user' do
    let(:scope) { create :line_item_scope, visible_for: user_roles }
    let(:user) { create :user, role: role }

    subject { scope.visible_for_user?(user) }

    context 'outfitters' do
      let(:role) { :outfitter }

      context 'when outfitter is in' do
        let(:user_roles) { ['admin', 'ops', 'outfitter'] }

        it { is_expected.to be true }
      end

      context 'when outfitter is out' do
        let(:user_roles) { ['admin', 'ops'] }

        it { is_expected.to be false }
      end
    end

    context 'ops' do
      let(:role) { :ops }

      context 'when ops is in' do
        let(:user_roles) { ['ops'] }

        it { is_expected.to be true }
      end

      context 'when ops is out' do
        let(:user_roles) { ['admin', 'outfitter'] }

        it { is_expected.to be false }
      end
    end

    context 'admins' do
      let(:role) { :admin }

      context 'when admin is in' do
        let(:user_roles) { ['admin'] }

        it { is_expected.to be true }
      end

      context 'when admin is out' do
        let(:user_roles) { ['ops'] }

        it { is_expected.to be false }
      end
    end
  end
end
