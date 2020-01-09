class Invoice < ActiveRecord::Base
  has_many :invoice_alteration_summaries, dependent: :destroy
  has_one :invoice_file, dependent: :destroy
  has_many :alteration_summaries, through: :invoice_alteration_summaries
  has_many :files, class_name: 'InvoiceFile'
  belongs_to :alteration_tailor

  enum status: %i(invoiced paid)

  scope :for_tailor, -> (tailor_id) { joins(:alteration_tailor).where(alteration_tailors: { id: tailor_id }) }
end
