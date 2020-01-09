class FabricManagerMailer < ActionMailer::Base
  def notify_about_unavailable_fabrics(user_id:, fabric_notifications_ids:)
    @user = User.find(user_id)
    fabric_notifications = FabricNotification.where(id: fabric_notifications_ids)
    @added = fabric_notifications.added
    @updated = fabric_notifications.updated
    @removed = fabric_notifications.removed

    mail(to: @user.email, subject: 'Fabric OOS/Discontinued List')
  end
end
