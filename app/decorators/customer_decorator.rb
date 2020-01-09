# frozen_string_literal: true

class CustomerDecorator < Draper::Decorator
  delegate_all
  decorates_association :profile

  STATUS_LABELS = {
    'to_be_fixed'     => 'label label-warning',
    'to_be_reviewed'  => 'label label-warning',
    'to_be_submitted' => 'label label-warning',
    'submitted'       => 'label label-success',
    'confirmed'       => 'label label-info',
    'n/a'             => 'label label-default'
  }.freeze
  CATEGORIES = ['Height', 'Shirt', 'Jacket', 'Pants', 'Waistcoat',
                'Overcoat', 'Chinos', 'Body shape & postures'].freeze
  NO_CATEGORY_STATUS = 'n/a'
  TO_BE_REVIEWED_STATUS = 'to_be_reviewed'
  TO_BE_CHECKED_STATUS = 'to_be_checked'

  def name_for_select
    "#{first_name} #{last_name} #{email}"
  end

  def name_for_email
    "#{first_name} #{last_name}"
  end

  def order_numbers
    orders.pluck(:number).join(', ')
  end

  def category_status(category_name)
    status =
      if profile.nil?
        NO_CATEGORY_STATUS
      else
        profile.category_status(category_name) || NO_CATEGORY_STATUS
      end

    { status: status, class: STATUS_LABELS[status] }
  end

  def non_adjustable_items
    created_category_names = profile&.categories_with_states(states: %i(to_be_fixed to_be_reviewed to_be_submitted))
    created_category_names << profile&.categories_with_states(states: :submitted) if created_category_names

    return [] unless created_category_names
    not_pending_items =
      line_items.with_categories(created_category_names.flatten)
        .without_states(
          :payment_pending, :new, :waiting_for_confirmation, :no_measurement_profile,
          :to_be_fixed_profile, :to_be_reviewed_profile, :to_be_submitted_profile, :cancelled,
          :refunded, :deleted_item, :completed, :remade
        )

    not_pending_items.map(&:local_category).flatten.uniq
  end

  def can_be_adjusted?
    non_adjustable_items&.any?
  end

  def can_be_reviewed_by?(user)
    return if TO_BE_CHECKED_STATUS.in?(unsubmitted_categories.map(&:status))

    return unless user.can_submit_measurements || user.can_review_measurements

    return if TO_BE_REVIEWED_STATUS.in?(unsubmitted_categories.map(&:status)) && !user.can_review_measurements

    h.can?(:review, Measurement) && unsubmitted_categories.any?
  end

  def can_be_checked_by?(user)
    return unless user.can_submit_measurements

    h.can?(:review, Measurement) && TO_BE_CHECKED_STATUS.in?(unsubmitted_categories.map(&:status))
  end

  def unsubmitted_categories
    @unsubmitted_categories ||= profile&.categories&.visible&.unsubmitted || []
  end

  # def height_status
  # def shirt_status
  # def jacket_status
  # def pants_status
  # def waistcoat_status
  # def overcoat_status
  # def chinos_status
  # def body_shape_postures_status
  CATEGORIES.each do |category|
    define_method("#{category.parameterize.underscore}_status") { category_status(category) }
  end
end
