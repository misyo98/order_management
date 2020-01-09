# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::AlterationSummary do
  describe '#summary_info' do
    let(:outfitter) { create(:user) }
    let!(:jacket) { create(:category, visible: true, name: 'Jacket') }

    context 'valid params' do
      let(:category) { create(:category, visible: true) }
      let(:param) { create(:param) }
      let(:category_param) { create(:category_param, category: category, param: param) }

      let(:decrease_profiles) { create_list(:profile, 2, author: outfitter) }
      let(:increase_profiles) { create_list(:profile, 2, author: outfitter) }

      let(:decrease_measurements) { decrease_profiles.each { |profile| create(:measurement, category_param: category_param, profile: profile, adjustment: -1) } }
      let(:increase_measurements) { increase_profiles.each { |profile| create(:measurement, category_param: category_param, profile: profile, adjustment: 2) } }

      let(:decrease_alterations) { Measurement.all.limit(2).each { |measurement| create(:alteration, measurement: measurement, value: -1) } }
      let(:increase_alterations) { Measurement.all.offset(2).each { |measurement| create(:alteration, measurement: measurement, value: 1) } }

      context 'with adjustments' do
        before :each do
          decrease_measurements
          increase_measurements

          @summaries = Admin::AlterationSummary.new(user_id: outfitter.id, start: Date.yesterday, end_date: Date.today).summary_info
          @target_summary = @summaries.detect { |summary| summary.category_param[:id] == category_param.id }
        end

        it 'calculates properly' do
          expect(@summaries).to be_kind_of Array
          expect(@summaries).not_to be_empty
          expect(@target_summary.alter_total).to eq 0
          expect(@target_summary.adjustment_increase).to eq increase_profiles.count
          expect(@target_summary.adjustment_decrease).to eq decrease_profiles.count
          expect(@target_summary.total_submissions).to eq (decrease_profiles.count + increase_profiles.count)
          expect(@target_summary.alter_percentage).to eq 0
        end
      end

      context 'with alterations' do
        before :each do
          decrease_measurements
          increase_measurements

          decrease_alterations
          increase_alterations

          @summaries = Admin::AlterationSummary.new(user_id: outfitter.id, start: Date.yesterday, end_date: Date.today).summary_info
          @target_summary = @summaries.detect { |summary| summary.category_param[:id] == category_param.id }
          @total_alterations = decrease_alterations.count + increase_alterations.count
        end

        it 'calculates alteration increase properly' do
          total_submissions = decrease_profiles.count + increase_profiles.count
          calculations = (@total_alterations.to_f / total_submissions.to_f * 100).round(2)

          expect(@target_summary.alter_increase).to eq increase_alterations.count
          expect(@target_summary.alter_decrease).to eq decrease_alterations.count
          expect(@target_summary.alter_total).to eq @total_alterations
          expect(@target_summary.alter_percentage).to eq calculations
        end
      end
    end

    context 'invalid params' do
      it 'returns an array with zero totals if params are empty' do
        summaries = Admin::AlterationSummary.new().summary_info

        expect(summaries).to be_kind_of Array
        expect(summaries).not_to be_empty
      end
    end
  end
end
