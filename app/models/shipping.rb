class Shipping < ActiveRecord::Base
  belongs_to :shippable, polymorphic: true
end
