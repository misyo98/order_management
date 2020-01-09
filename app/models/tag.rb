class Tag < ActiveRecord::Base
  has_many :line_item_tags, dependent: :destroy
  has_many :line_items, through: :line_item_tags
end
