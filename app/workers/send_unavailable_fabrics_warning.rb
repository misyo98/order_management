class SendUnavailableFabricsWarning
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(fabric_notifications_ids)
    User.where(role: [1, 2]).each do |user|
      FabricManagerMailer.notify_about_unavailable_fabrics(
        user_id: user.id,
        fabric_notifications_ids: fabric_notifications_ids
      ).deliver_now
    end
  end
end
