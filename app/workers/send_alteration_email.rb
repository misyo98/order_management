class SendAlterationEmail
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def perform(customer_id, submitter_id)
    customer = Customer.find_by(id: customer_id)
    submitter = User.find_by(id: submitter_id)
    AlterationMailer.after_alteration(customer: customer, submitter: submitter).deliver_now
  end
end
