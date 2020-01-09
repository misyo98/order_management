class RefundReason < ActiveRecord::Base
  default_scope { order(order: :asc) }
end
