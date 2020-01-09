class InvoiceAlterationSummary < ActiveRecord::Base
  belongs_to :invoice
  belongs_to :alteration_summary
end
