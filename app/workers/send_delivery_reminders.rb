class SendDeliveryReminders
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
    LineItem.with_state(:delivery_email_sent).remindable.find_each do |item|
      if item.state_entered_date && item.state_entered_date <= 5.days.ago
        EmailsQueues::CreateDeliveryEmail.(item)
      end
    end
  end
end
