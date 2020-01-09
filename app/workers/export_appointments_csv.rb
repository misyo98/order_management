class ExportAppointmentsCsv
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(user_id, params)
    csv_data = BookingTool::ExportCSV.(User.find(user_id), params)
    csv = TmpFileManager.save_data_as_csv(csv_data, 'appointments')

    Pusher.trigger('appointments-csv-channel', 'csv-generated-event', {
      id: csv.id
    })
    CleanDownloadedTempFiles.perform_in(10.minutes, id: csv.id)
  end
end
