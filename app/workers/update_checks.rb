class UpdateChecks
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(ids = [])
    Measurements::CheckUpdater.new(ids: ids).update
  end
end