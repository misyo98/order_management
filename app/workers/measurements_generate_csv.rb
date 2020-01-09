class MeasurementsGenerateCsv
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(params)
    profiles = Profile.ransack(params).result
      .includes(
        :author, :fits, :categories, measurements: [adjustment_value: :value, alterations: [category_param_value: :value],
        category_param_value: :value, category_param: :param], customer: :comments
      ).uniq

    temp_file = Exporters::Objects::Measurements.new(profiles: profiles).call
    new_file = TmpFileManager.save_data_as_csv(temp_file, 'measurements')

    send_file_link(new_file)

    CleanDownloadedTempFiles.perform_in(10.minutes, id: new_file.id )
  end

  private

  def send_file_link(new_file)
    begin
      retries ||= 0

      Pusher.trigger('measurements-csv-channel', 'measurements-csv-generated-event', {
        url: "#{new_file.attachment_url}",
        id: new_file.id,
      })
    rescue Pusher::Error => error
      puts "#{DateTime.current}: Pusher error - #{error.message}"

      retry if (retries += 1) < 3
    end
  end
end
