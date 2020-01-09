class ImportFabricInfos
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(encoded_csv_content)
    tempfile = TmpFileManager.save_data_as_csv(Base64.strict_decode64(encoded_csv_content), 'fabric_infos')
    Importers::Objects::FabricInfos.new(tempfile_path: tempfile.attachment.file.path).call
    tempfile.destroy
  end
end
