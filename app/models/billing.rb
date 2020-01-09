class Billing < ActiveRecord::Base
  include Findable
  
  belongs_to :billable, polymorphic: true
  belongs_to :order, -> { where( billings: { billable_type: 'Order' } ).includes( :billings ) }, foreign_key: :billable_id

  scope :with_orders_in_date, ->(date:) { joins(:order)
    .where(Order.arel_table[:created_at].gteq(date).and(Order.arel_table[:created_at].lteq(date + 7.days))) }
end
