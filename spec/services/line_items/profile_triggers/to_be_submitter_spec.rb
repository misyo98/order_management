# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LineItems::ProfileTriggers::ToBeSubmitter do
  let(:user) { create :user }
  let(:profile) { create :profile }
  let!(:shirt_product) { create :product, category: 'MADE-TO-MEASURE SHIRTS' }
  let!(:pants_product) { create :product, category: 'MADE-TO-MEASURE TROUSERS' }
  let!(:chinos_product) { create :product, category: 'MADE-TO-MEASURE CHINOS' }
  let(:shirt_category) { create :category, name: 'Shirt', visible: true }
  let(:pants_category) { create :category, name: 'Pants', visible: true }
  let(:chinos_category) { create :category, name: 'Chinos', visible: true }
  let!(:saved_category) { create :profile_category, profile: profile, category: pants_category }
  let!(:to_be_submitted_category) { create :profile_category, profile: profile, status: :to_be_submitted, category: shirt_category }
  let!(:other_confirmed_category) { create :profile_category, profile: profile, status: :confirmed, category: chinos_category }
  let!(:order) { create :order, customer: profile.customer, status: :completed }
  let!(:item1) { create :line_item, state: :to_be_checked_profile, order: order, product: shirt_product, manufacturer: :new_manufacturer }
  let!(:item2) { create :line_item, state: :fabric_received, order: order, product: shirt_product }
  let!(:item3) { create :line_item, state: :waiting_for_confirmation, order: order, product: pants_product }

  subject { described_class.to_be_submitted(customer: profile.customer, user_id: user.id) }

  it 'changes the item states properly' do
    subject

    item1.reload
    item2.reload
    item3.reload

    expect(item1.state).to eq 'to_be_submitted_profile'
    expect(item2.state).to eq 'fabric_received'
    expect(item3.state).to eq 'waiting_for_confirmation'
  end
end
