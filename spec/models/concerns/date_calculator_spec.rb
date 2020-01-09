require 'rails_helper'

RSpec.describe DateCalculator do
  let(:test_class) { Class.new.extend(DateCalculator) }

  describe '#too_far_apart?' do
    let(:start_date) { Date.today.monday }
    let(:end_date) { start_date + 6.days } # Sunday

    subject { test_class.too_far_apart?(start_date, end_date, valid_range, work_days) }

    context 'with all days range' do
      let(:work_days) { false }

      context 'when start date is out of valid range' do
        let(:valid_range) { 5 }

        it { is_expected.to be true }
      end

      context 'when start date is in valid range' do
        let(:valid_range) { 7 }

        it { is_expected.to be false }
      end
    end

    context 'with only working days range' do
      let(:work_days) { true }

      context 'when start date is out of valid range' do
        let(:valid_range) { 3 }

        it { is_expected.to be true }
      end

      context 'when start date is in valid range' do
        let(:valid_range) { 5 }

        it { is_expected.to be false }
      end

      context 'when start date is Monday' do
        let(:valid_range) { 4 }
        let(:next_monday_end_date) { start_date + 7.days } # next Monday

        it 'is valid on Friday' do
          expect(subject).to be false
        end

        it 'is invalid next Monday' do
          result = test_class.too_far_apart?(start_date, next_monday_end_date, valid_range, work_days)

          expect(result).to be true
        end
      end

      context 'over the weekends with 1 day range' do
        let(:start_date) { Date.today.monday + 4.days } # Friday
        let(:valid_range) { 1 }

        context 'should still be in range on Monday' do
          let(:end_date) { start_date + 3.days } # Monday

          it { is_expected.to be false }
        end

        context 'should not be in range on Tuesday' do
          let(:end_date) { start_date + 4.days } # Tuesday

          it { is_expected.to be true }
        end
      end
    end
  end
end
