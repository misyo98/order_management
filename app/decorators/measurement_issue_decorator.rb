# frozen_string_literal: true

class MeasurementIssueDecorator < Draper::Decorator
  PROFILE_TYPE = 'Profile'
  MEASUREMENT_TYPE = 'Measurement'

  delegate_all

  def customer_name
    profile.customer_full_name
  end

  def customer_id
    profile.customer_id
  end

  def outfitter
    return if issueable_type == PROFILE_TYPE
    profile_category = profile.categories.find_by(category_id: issueable.category_id)

    profile_category&.author&.full_name
  end

  def category_name
    return if issueable_type == PROFILE_TYPE

    issueable.category_name
  end

  def measurement_name
    return if issueable_type == PROFILE_TYPE

    issueable.param_title
  end

  def time_to_be_fixed
    return unless fixed?

    h.distance_of_time_in_words(created_at, updated_at)
  end

  private

  def profile
    case issueable_type
    when MEASUREMENT_TYPE
      issueable.profile
    when PROFILE_TYPE
      issueable
    end
  end
end
