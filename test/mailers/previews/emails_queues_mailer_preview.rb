class EmailsQueuesMailerPreview < ActionMailer::Preview
  def delivery_email
    EmailsQueuesMailer.delivery_email(EmailsQueue.last)
  end

  def shipping_email
    EmailsQueuesMailer.shipping_email(EmailsQueue.last)
  end
end
