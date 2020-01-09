class LineItemScopeSalesLocation < ActiveRecord::Base
  belongs_to :line_item_scope
  belongs_to :sales_location
end
