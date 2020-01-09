class SendNonDuplicateAlterationEmail
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(customer_id, submitter_id, target_users_ids)
    customer = Customer.find_by(id: customer_id)
    submitter = User.find_by(id: submitter_id)
    target_users = User.where(id: target_users_ids)
    local_users = target_users.where(country: customer.billing&.country) if target_users

    if local_users.any?
      local_users.each do |user|
        AlterationMailer.after_alteration_to_staff(
          customer: customer,
          submitter: submitter,
          user: user
        ).deliver_now
      end
    elsif target_users.any?
      target_users.each do |user|
        AlterationMailer.after_alteration_to_staff(
          customer: customer,
          submitter: submitter,
          user: user
        ).deliver_now
      end
    end
  end
end
