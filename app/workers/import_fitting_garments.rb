class ImportFittingGarments
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(encoded_csv_content)
    tempfile = TmpFileManager.save_data_as_csv(Base64.decode64(encoded_csv_content), 'fitting_garments')
    Importers::Objects::FittingGarments.new(tempfile_path: tempfile.attachment.file.path).call
    tempfile.destroy
  end
end
