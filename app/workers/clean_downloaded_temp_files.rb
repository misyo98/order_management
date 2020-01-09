class CleanDownloadedTempFiles
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(params)
    TempFile.find_by(params[:id]).destroy
  end
end
