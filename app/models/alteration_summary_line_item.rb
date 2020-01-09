class AlterationSummaryLineItem < ActiveRecord::Base
  belongs_to :alteration_summary
  belongs_to :line_item
  belongs_to :alteration_tailor
end
