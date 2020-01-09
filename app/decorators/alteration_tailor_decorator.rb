class AlterationTailorDecorator < Draper::Decorator
  delegate_all

  def alteration_costs
    "Costs #{formatted_currency}"
  end
  
  def formatted_currency
    model.currency.upcase
  end
end
