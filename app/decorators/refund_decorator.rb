class RefundDecorator < Draper::Decorator
  OTHER_REASON = 'Other'

  delegate_all

  def customer_full_name
    "#{order_billing_first_name} #{order_billing_last_name}"
  end

  def shipping_country
    order_shipping_country
  end

  def refund_amount
    amount
  end

  def refund_currency
    order_currency
  end

  def refund_reason
    if other_reason?
      "#{reason} - #{comment}"
    else
      reason
    end
  end

  def refund_date
    h.l(created_at, format: :order_date)
  end

  def list_price
    subtotal.to_f / 100
  end

  def paid_price
    total.to_f / 100
  end

  def vat_export_status
    return if vat_export.nil?

    vat_export ? 'YES' : 'NO'
  end

  def order_date
    h.l(order_created_at, format: :order_date)
  end

  private

  def other_reason?
    reason == OTHER_REASON
  end
end
