class AlterationMailer < ActionMailer::Base
  def after_alteration(customer:, submitter:)
    @submitter = submitter.decorate
    @author    = customer.profile.author.decorate
    @customer  = customer.decorate
    mail(to: @author.email, subject: "Alteration Submitted to #{@customer.name_for_email} by #{@submitter.name}")
  end

  def after_alteration_to_staff(customer:, submitter:, user:)
    @submitter = submitter.decorate
    @author = customer.profile.author.decorate
    @customer = customer.decorate
    @user = user.decorate
    mail(to: user.email, subject: "Alteration submitted to #{@customer.name_for_email} by #{@submitter.name}")
  end

  def after_alteration_violations(customer:, submitter:, user:, violations:)
    @submitter = submitter.decorate
    @author = customer.profile.author.decorate
    @customer = customer.decorate
    @user = user.decorate
    @violations = JSON.parse(violations)
    mail(to: user.email, subject: "Alteration Validation Violations - Alteration submitted to #{@customer.name_for_email} by #{@submitter.name}")
  end
end
