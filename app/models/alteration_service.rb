class AlterationService < ActiveRecord::Base
  acts_as_paranoid

  has_many :alteration_service_tailors, dependent: :destroy, inverse_of: :alteration_service
  has_many :alteration_summary_services
  has_many :alteration_summaries, through: :alteration_summary_services
  belongs_to :category
  belongs_to :author, class_name: 'User'

  accepts_nested_attributes_for :alteration_service_tailors

  validates :category_id, :name, :order, presence: true
  validate :existing_service

  scope :non_zero, -> { where(AlterationServiceTailor.arel_table[:price].gt(0)) }

  private

  def existing_service
    exists =
      alteration_service_tailors
        .with_tailor_not_nil_price(author&.alteration_tailor_id)
        .first

    errors.add(
      :service_exists,
      "'#{name}': if you need to change the cost, contact your admin"
    ) if exists
  end
end
