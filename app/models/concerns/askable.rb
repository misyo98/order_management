module Askable
  def asknicely
    email = order_billing_email
    first_name = order_billing_first_name
    last_name = order_billing_last_name
    segment = order_currency == 'SGD' ? 'Singapore - After Delivery' : 'London - After Delivery'

    Asknicely::API.new(email: email, first_name: first_name, last_name: last_name, segment: segment).send_survey
  end
end