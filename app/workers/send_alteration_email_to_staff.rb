class SendAlterationEmailToStaff
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(customer_id, submitter_id)
    customer = Customer.find_by(id: customer_id)
    submitter = User.find_by(id: submitter_id)
    company_users = User.where(receive_all_alteration_emails: true, country: customer.billing&.country)
    if company_users.any?
      company_users.each do |user|
        AlterationMailer.after_alteration_to_staff(
          customer: customer,
          submitter: submitter,
          user: user
        ).deliver_now
      end
    else
      User.where(receive_all_alteration_emails: true).each do |user|
        AlterationMailer.after_alteration_to_staff(
          customer: customer,
          submitter: submitter,
          user: user
        ).deliver_now
      end
    end
  end
end
