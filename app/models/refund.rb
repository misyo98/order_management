class Refund < ActiveRecord::Base
  belongs_to :line_item

  validates :amount, numericality: { greater_than: 0 }
  validates :reason, presence: true

  delegate :order_number, :order_billing_first_name, :order_billing_last_name,
           :product_title, :order_currency, :vat_export, :subtotal, :total,
           :order_shipping_country, :order_created_at, to: :line_item
end
