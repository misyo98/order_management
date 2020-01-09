class EmailsQueuesMailer < ActionMailer::Base
  def delivery_email(email)
    @recipient = email.recipient
    @token = @recipient.token
    @link = email.options.fetch(:link)
    @order_number = email.subject.order_number

    subject = email.options.fetch(:subject)
    from = "Edit Suits Co. <#{email.options[:from]}>"

    mail(from: from, to: @recipient.email, subject: subject) do |format|
      format.html { render email.with_courier_button? ? 'delivery_email_with_courier_button' : 'delivery_email' }
    end
  end

  def shipping_email(email)
    @recipient = email.recipient
    @number = email.tracking_number
    @link = email.options.fetch(:link)
    subject = email.options[:subject]
    from = "Edit Suits Co. <#{email.options[:from]}>"

    mail(from: from, to: @recipient.email, subject: subject)
  end

  def not_sent_emails_warning_email(recipient, emails)
    @not_sent_emails = emails

    mail(from: 'Edit Suits Co.', to: recipient, subject: 'Emails were not sent')
  end
end
