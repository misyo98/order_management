class AlterationServiceTailor < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :alteration_service
  belongs_to :alteration_tailor

  delegate :name, to: :alteration_tailor, prefix: true

  scope :with_tailor_not_nil_price, -> (tailor_id) { where(alteration_tailor_id: tailor_id).where.not(price: nil) }
end
