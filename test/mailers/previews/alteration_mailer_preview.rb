class AlterationMailerPreview < ActionMailer::Preview
  def after_alteration
    AlterationMailer.after_alteration(customer: Profile.first.customer, submitter: User.first)
  end
end
