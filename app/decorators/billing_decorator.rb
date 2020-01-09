class BillingDecorator < Draper::Decorator
  delegate_all

  def name_for_select
    "#{first_name} #{last_name} #{email}"
  end
end
