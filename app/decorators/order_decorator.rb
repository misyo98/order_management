class OrderDecorator < Draper::Decorator
  delegate_all

  def formatted_total
    total.fdiv(100).round(2)
  end

  def formatted_subtotal
    @formatted_subtotal ||= line_items.decorate.map(&:list_price).inject(:+)
  end

  def formatted_total_tax
    total_tax.fdiv(100).round(2)
  end

  def formatted_discount
    (formatted_subtotal - formatted_total).abs
  end
end
