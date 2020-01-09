class AlterationInfo < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :profile
  belongs_to :category
  belongs_to :author, -> { with_deleted }, class_name: 'User'
  belongs_to :alteration_summary

  delegate :name, to: :category, prefix: true
  delegate :first_name, :last_name, :email, :full_name, to: :author, prefix: true, allow_nil: true

  scope :for_customer, ->(customer_id:) { joins(profile: :customer).where(Customer.arel_table[:id].eq(customer_id)) }

  scope :for_summaries, -> (author_id:, start_date:, end_date:) {
    where(category_id: Category.jacket.id)
      .where(arel_table[:updated_at].gteq(start_date))
      .where(arel_table[:updated_at].lteq(end_date))
      .joins(:category).joins(:profile).where(Profile.arel_table[:author_id].eq(author_id))
  }
end
