class AlterationTailor < ActiveRecord::Base
  enum currency: %i(gbp sgd)

  validates :currency, presence: true

  has_many :alteration_service_tailors
  has_many :alteration_services, -> { order(AlterationServiceTailor.arel_table[:order].asc) },
                                 through: :alteration_service_tailors, dependent: :nullify
  has_many :alteration_summary_line_items, dependent: :nullify
  has_many :invoices, dependent: :nullify
end
