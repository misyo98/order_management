# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MeasurementsGenerateCsv, type: :job do
  describe 'csv file generator' do
    let!(:customer) { create :customer }
    let!(:shipping) { create :shipping, country: 'Bretonia', shippable: customer }
    let!(:profile) { create :profile, customer: customer }
    let(:params) { { 'customer_shipping_country_in' => ['Bretonia'] } }

    it 'creates csv file to be downloaded' do
      expect { described_class.perform_async }.to change { Sidekiq::Worker.jobs.size }.by 1
      expect { described_class.new.perform(params: params) }.to change { TempFile.count }.by 1
    end

    it 'removes file' do
      file = TempFile.create(attachment: 'to_be_deleted.csv')

      expect { CleanDownloadedTempFiles.new.perform(id: file.id) }.to change { TempFile.count }.by -1
    end
  end
end
