class FabricInfosGenerateCsv
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
    fabric_infos = FabricInfo.without_deleted.all
    temp_file = Exporters::Objects::FabricInfos.new(records: fabric_infos).call
    new_file = TmpFileManager.save_data_as_csv(temp_file, 'fabric-infos')

    send_file_link(new_file)

    CleanDownloadedTempFiles.perform_in(10.minutes, id: new_file.id )
  end

  private

  def send_file_link(new_file)
    begin
      retries ||= 0

      Pusher.trigger('csv-channel', 'fabric-infos-csv-generated-event', {
        url: "#{new_file.attachment_url}",
        id: new_file.id
      })
    rescue Pusher::Error => error
      puts "#{DateTime.current}: Pusher error - #{error.message}"

      retry if (retries += 1) < 3
    end
  end
end
