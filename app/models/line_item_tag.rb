class LineItemTag < ActiveRecord::Base
  belongs_to :tag
  belongs_to :line_item
end
