# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AlterationSummariesController, type: :controller do
  let!(:tailor) { create :alteration_tailor }
  let!(:user) { create(:user) }

  before(:each) { sign_in user }

  describe 'PATCH #update' do
    let!(:summary) { create :alteration_summary }

    context 'with valid attributes' do
      it 'updates' do
        patch :update, id: summary, alteration_summary: { amount: 21 }

        summary.reload

        expect(summary.amount).to eq 21
      end
    end
  end

  describe 'PATCH #update_services' do
    let!(:summary) { create :alteration_summary }
    let!(:service) { create :alteration_service, name: 'test' }
    let!(:service1) { create :alteration_service, name: 'test1' }
    let!(:service_tailor) { create :alteration_service_tailor, alteration_service: service, alteration_tailor: nil, price: 40 }
    let!(:service_tailor1) { create :alteration_service_tailor, alteration_service: service1, alteration_tailor: nil, price: 40 }

    context 'update alteration service ids for summary' do
      it 'changes comment of the summary' do
        patch :update_services, format: :js, id: summary, alteration_summary: attributes_for(
          :alteration_summary, alteration_service_ids: [service.id, service1.id])

        summary.reload

        expect(summary.alteration_service_ids).to contain_exactly service.id, service1.id
        expect(summary.amount).to eq 80
      end
    end
  end

  describe 'alteration summary states' do

    context 'alteration summaries with different states' do
      let(:summary_params) { { alteration_tailor_id: tailor.id, line_item_ids: [] } }

      it 'creates summary with initial state' do
        expect { post :create, alteration_summary: summary_params }
          .to change { AlterationSummary.count }.by 1
        expect(AlterationSummary.last.to_be_altered?).to be true
      end
    end

    context 'update of alteration summary' do
      let!(:summary) { create :alteration_summary, state: 'to_be_updated' }
      let!(:summary2) { create :alteration_summary, state: 'to_be_altered' }
      let!(:service) { create :alteration_service, name: 'test' }
      let!(:service2) { create :alteration_service, name: 'test 2' }
      let!(:service_tailor) { create :alteration_service_tailor, alteration_service: service, alteration_tailor: tailor, price: 10 }
      let!(:service_tailor2) { create :alteration_service_tailor, alteration_service: service2, alteration_tailor: tailor, price: 15 }
      let(:summary_params) { { alteration_tailor_id: tailor.id, line_item_ids: [] } }

      it 'updates summary with services and to_be_invoiced state' do
        patch :update_services, format: :js, id: summary, alteration_summary: attributes_for(
          :alteration_summary, alteration_service_ids: [service.id])

        patch :update_services, format: :js, id: summary2, alteration_summary: attributes_for(
          :alteration_summary, alteration_service_ids: [service2.id])

        [summary, summary2].each(&:reload)

        expect(summary.to_be_invoiced?).to be true
        expect(summary2.to_be_invoiced?).to be true
        expect(summary.alteration_service_ids).to contain_exactly service.id
        expect(summary2.alteration_service_ids).to contain_exactly service2.id
      end
    end
  end

  describe 'PATCH #update_with_alterations' do
    let!(:summary) { create :alteration_summary }
    let!(:customer) { create :customer }
    let!(:profile) { create :profile, customer: customer }
    let!(:category) { create :category }
    let!(:param) { create :param }
    let!(:category_param) { create :category_param, category: category, param: param }
    let!(:profile_category) { create :profile_category, profile: profile, category: category }
    let!(:measurement) { create :measurement, profile: profile, final_garment: 1, category_param: category_param }
    let!(:requested_action) { 'Alteration requested' }
    let!(:selected_categories) { "#{category.name}" }
    let!(:update) { false }

    let(:profile_params) do
      {
        measurements_attributes: {
          measurement.id => {
            id: measurement.id,
            post_alter_garment: 5,
            alterations_attributes: {
              1 => {
                value: 1,
                author_id: user.id,
                measurement_id: measurement.id,
                category_id: category.id
              }
            }
          }
        }
      }
    end

    let(:summary_params) do
      {
        urgent: false,
        requested_completion: '2019-03-26',
        alteration_request_taken: '2019-03-30',
        delivery_method: 'courier',
        non_altered_items: 'all_altered',
        remaining_items: 'trigger_after_alteration'
      }
    end

    context 'with invalid attributes' do
      it 'does not change attributes' do
        expect { patch :update_with_alterations, id: summary, format: :js,
          customer_id: customer.id,
          requested_action: requested_action,
          selected_categories: selected_categories,
          alteration_infos: {
            1 => {
              comment: 'comment',
              manufacturer_code: 'm_code',
              category_id: category.id,
              profile_id: profile.id,
              author_id: user.id,
            }
          },
          profile_categories: {
            profile_category.id => {
              status: 'submitted'
            }
          },
          profile: profile_params,
          alteration_summary: summary_params
        }.to change { Sidekiq::Worker.jobs.size }.by 2
      end
    end
  end

  describe '#back_from_alteration' do
    let!(:item1) { create :line_item, state: 'being_altered', alteration_tailor_id: tailor.id }
    let!(:item2) { create :line_item, state: 'being_altered', alteration_tailor_id: tailor.id }
    let!(:summary_item1) { create :alteration_summary_line_item, line_item: item1, alteration_tailor: tailor }
    let!(:summary_item2) { create :alteration_summary_line_item, line_item: item2, alteration_tailor: tailor }
    let!(:summary) do
      create :alteration_summary, alteration_summary_line_items: [summary_item1, summary_item2], line_item_ids: [item1.id, item2.id], state: 'to_be_altered'
    end

    it 'moves summary to to_be_updated queue and all altered line_items to back_from_alteration state' do
      expect(summary.state).to eq 'to_be_altered'
      expect(summary.items).to contain_exactly item1, item2
      expect(item1.state).to eq 'being_altered'
      expect(item2.state).to eq 'being_altered'

      patch :back_from_alteration, id: summary.id, format: :js

      [item1, item2, summary].each(&:reload)

      expect(summary.state).to eq 'to_be_updated'
      expect(item1.state).to eq 'single_at_office'
      expect(item2.state).to eq 'single_at_office'
    end

    it 'updates alteration summary and only one line_item when another was already brought back from alteration' do
      item2.update_column(:state, 'waiting_for_items_alteration')

      expect(item1.state).to eq 'being_altered'
      expect(item2.state).to eq 'waiting_for_items_alteration'

      patch :back_from_alteration, id: summary.id, format: :js

      [item1, item2, summary].each(&:reload)

      expect(summary.state).to eq 'to_be_updated'
      expect(item1.state).to eq 'single_at_office'
      expect(item2.state).to eq 'waiting_for_items_alteration'
    end

    it 'does not update anything for summary with incorrect state' do
      summary.update_column(:state, 'to_be_updated')

      expect(summary.state).to eq 'to_be_updated'

      patch :back_from_alteration, id: summary.id, format: :js

      [item1, item2, summary].each(&:reload)

      expect(summary.state).to eq 'to_be_updated'
      expect(item1.state).to eq 'being_altered'
      expect(item2.state).to eq 'being_altered'
    end
  end
end
