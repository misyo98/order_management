# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profiles::Alteration do
  let(:customer) { create :customer }
  let(:profile) { create :profile, customer: customer }
  let(:user) { create :user }
  let(:category) { create :category }
  let(:category2) { create :category }
  let(:param) { create :param }
  let(:param2) { create :param }
  let(:category_param) { create :category_param, category: category, param: param }
  let(:category_param2) { create :category_param, category: category2, param: param2 }
  let(:profile_category) { create :profile_category, profile: profile, category: category }
  let(:profile_category2) { create :profile_category, profile: profile, category: category2 }
  let(:line_item) { create :line_item, state: :completed, delivery_method: nil }
  let(:line_item2) { create :line_item, state: :completed, delivery_method: nil }
  let(:measurement) { create :measurement, profile: profile, final_garment: 1, category_param: category_param }
  let(:measurement2) { create :measurement, profile: profile, final_garment: 1, category_param: category_param2 }
  let(:line_item_ids) { "#{line_item.id} #{line_item2.id}" }
  let(:requested_action) { 'Alteration requested' }
  let(:selected_categories) { "#{category.name}, #{category2.name}" }
  let(:summary) { nil }
  let(:update) { false }

  let(:profile_params) do
    {
      measurements_attributes: {
        measurement.id => {
          id: measurement.id,
          final_garment: 1,
          post_alter_garment: 2,
          alterations_attributes: {
            1 => {
              value: 1,
              author_id: user.id,
              measurement_id: measurement.id,
              category_id: category.id
            }
          }
        },
        measurement2.id => {
          id: measurement2.id,
          final_garment: 1,
          post_alter_garment: 2,
          alterations_attributes: {
            2 => {
              value: 1,
              author_id: user.id,
              measurement_id: measurement2.id,
              category_id: category2.id
            }
          }
        }
      }
    }
  end

  let(:params) do
    ActionController::Parameters.new({
      customer_id: customer.id,
      line_item_ids: line_item_ids,
      requested_action: requested_action,
      selected_categories: selected_categories,
      alteration_infos: {
        1 => {
          comment: 'comment1',
          manufacturer_code: 'code',
          category_id: category.id,
          profile_id: profile.id,
          author_id: user.id,
        },
        2 => {
          comment: 'comment2',
          manufacturer_code: 'code2',
          category_id: category2.id,
          profile_id: profile.id,
          author_id: user.id,
        }
      },
      profile_categories: {
        profile_category.id => {
          status: 'submitted'
        },
        profile_category2.id => {
          status: 'submitted'
        }
      },
      alteration_summary: {
        urgent: false,
        payment_required: true,
        requested_completion: '2019-02-06',
        alteration_request_taken: '2019-02-27',
        delivery_method: 'courier',
        non_altered_items: 'all_altered',
        remaining_items: 'trigger_after_alteration'
      }
    })
  end

  subject do
    described_class.perform(
      params,
      profile_params,
      user,
      summary,
      update: update
    )
  end

  it 'performs alteration flow correctly' do
    expect { subject }.to change { [AlterationSummary.count, AlterationInfo.count] }.by [1, 2]

    summary = AlterationSummary.last

    [measurement, measurement2, profile, line_item, line_item2].each(&:reload)

    [measurement, measurement2].each do |m|
      expect(m.alterations.last.value).to eq 1
      expect(m.alterations.last.alteration_summary_id).to eq summary.id
      expect(m.post_alter_garment).to eq 2
    end
    expect(summary.urgent).to be false
    expect(summary.payment_required).to be true
    expect(summary.requested_completion).to eq Date.new(2019, 02, 06)
    expect(summary.alteration_request_taken).to eq Date.new(2019, 02, 27)
    expect(summary.delivery_method).to eq 'courier'
    expect(summary.non_altered_items).to eq 'all_altered'
    expect(summary.remaining_items).to eq 'trigger_after_alteration'
    expect(profile.categories.map(&:status)).to match_array ['submitted', 'submitted']
    expect(line_item.state).to eq 'alteration_requested'
    expect(line_item.delivery_method).to eq 'courier'
    expect(line_item2.state).to eq 'alteration_requested'
    expect(line_item2.delivery_method).to eq 'courier'
  end

  context 'alteration to be saved without changing final_garments' do
    let(:params) do
      ActionController::Parameters.new({
        customer_id: customer.id,
        line_item_ids: line_item_ids,
        requested_action: requested_action,
        selected_categories: selected_categories,
        alteration_infos: {
          1 => {
            comment: 'comment1',
            manufacturer_code: 'code',
            category_id: category.id,
            profile_id: profile.id,
            author_id: user.id,
          },
          2 => {
            comment: 'comment2',
            manufacturer_code: 'code2',
            category_id: category2.id,
            profile_id: profile.id,
            author_id: user.id,
          }
        },
        profile_categories: {
          profile_category.id => {
            status: 'submitted'
          },
          profile_category2.id => {
            status: 'submitted'
          }
        },
        alteration_summary: {
          urgent: false,
          payment_required: true,
          requested_completion: '2019-02-06',
          alteration_request_taken: '2019-02-27',
          delivery_method: 'courier',
          non_altered_items: 'all_altered',
          remaining_items: 'trigger_after_alteration'
        },
        save_without_changes: 'present'
      })
    end

    subject do
      described_class.perform(
        params,
        profile_params,
        user,
        nil
      )
    end

    it 'saves without changing final_garments' do
      expect { subject }.to change { [AlterationSummary.count, AlterationInfo.count] }.by [1, 2]

      [measurement, measurement2, profile, line_item, line_item2].each(&:reload)

      expect(measurement.post_alter_garment).to eq 1
      expect(measurement2.post_alter_garment).to eq 1
      expect(profile.categories.map(&:status)).to match_array ['submitted', 'submitted']
      expect(line_item.state).to eq 'alteration_requested'
      expect(line_item.delivery_method).to eq 'courier'
      expect(line_item2.state).to eq 'alteration_requested'
      expect(line_item2.delivery_method).to eq 'courier'
    end
  end
end
