class AlterationSummaryService < ActiveRecord::Base
  belongs_to :alteration_summary
  belongs_to :alteration_service
end
