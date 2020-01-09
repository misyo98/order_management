class RealCog < ActiveRecord::Base
  belongs_to :cost_bucket
  belongs_to :line_item, foreign_key: :manufacturer_id, primary_key: :m_order_number

  delegate :id, to: :line_item, prefix: true, allow_nil: true
end
