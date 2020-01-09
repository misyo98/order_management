# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookingTool::AppointmentDecorator, type: :decorator do
  describe '#maybe_dropped_dates' do
    context 'appointment was dropped once' do
      let(:appointment) { double submitted: DateTime.yesterday.midday, dropped_events: [DateTime.current] }

      subject { described_class.decorate(appointment).maybe_dropped_dates }

      it 'returns dropped date' do
        expect(subject).to eq DateTime.yesterday.midday.strftime('%B %d %Y, %H:%M:%S')
      end
    end

    context 'appointment was dropped several times' do
      let(:appointment) { double dropped_events: [DateTime.current, DateTime.current.yesterday] }

      subject { described_class.decorate(appointment).maybe_dropped_dates }

      it 'returns link to see dropped history' do
        expect(subject).to match "<a data-remote=\"true\" href=\"/booking_tool/appointments/dropped_events"
      end
    end
  end
end
