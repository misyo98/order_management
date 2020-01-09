class Alteration < ActiveRecord::Base
  attr_accessor :category_id
  
  belongs_to :author, -> { with_deleted }, class_name: 'User'
  belongs_to :category_param_value
  belongs_to :measurement
  belongs_to :alteration_summary

  delegate :email, to: :author, prefix: true

  scope :customers_alterations, ->(customer_id:) { includes(:author).joins(measurement: [profile: :customer])
                                                   .where(Customer.arel_table[:id].eq customer_id) }

end
