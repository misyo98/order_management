namespace :fabric_unavailability_notification do
  desc 'Sends daily OOS/Discontinued fabrics list update emails if needed'
  task daily: :environment do
    notification_ids = FabricNotification.all.where(created_at: (DateTime.current - 24.hours)..DateTime.current).map(&:id)

    if notification_ids.any?
      SendUnavailableFabricsWarning.perform_async(
        notification_ids
      )
    end
  end
end
