require 'rails_helper'

RSpec.describe ExportAppointmentsCsv, type: :job do
  let(:user) { create :user }

  subject { described_class.new.perform(user.id, {}) }

  before do
    allow(BookingTool::ExportCSV).to receive(:call) { [1, 2].to_csv }
    allow(Pusher).to receive(:trigger) { true }
  end

  it 'works' do
    expect { subject }.to change { TempFile.count }.by 1
  end
end
