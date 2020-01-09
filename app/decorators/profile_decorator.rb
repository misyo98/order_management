class ProfileDecorator < Draper::Decorator
  delegate_all
  decorates_association :measurements

  PRE_HEADERS  = %w(category param body final\ garment\ measurements).freeze
  SHOW_HEADERS = ['category', 'measurement', 'body(inches)', 'allowance', 'adjustment', 'final garment'].freeze
  POST_HEADERS = %w(garment\ post\ alteration).freeze
  COPY_HEADERS = %w(category param final\ garment).freeze

  def author_name
    "#{model.author_first_name} #{model.author_last_name}"
  end

  def submitter_name
    "#{model.submitter_first_name} #{model.submitter_last_name}"
  end

  def url(customer)
    new_record? ? create_url(customer) : update_url(customer)
  end

  def http_method
    new_record? ? :post : :patch
  end

  def category_measurements(category_id:)
    measurements.select { |measurement| measurement.category_id == category_id }
  end

  def edit_headers(category: nil)
    headers = PRE_HEADERS.dup
    headers << 'Alteration'

    unless category&.name == 'Height' || category&.name == 'Body shape & postures'
      headers << POST_HEADERS
    end

    headers.flatten
  end

  def show_headers
    headers = SHOW_HEADERS.dup
    if alteration_summaries.any?
      max_alterations.times { |i| headers << "alteration #{i + 1}" }
      headers << POST_HEADERS
    end
    headers.flatten
  end

  def copy_headers
    COPY_HEADERS
  end

  def submitted_measurements?
    profile.categories.unsubmitted.none?
  end

  def alteration_colspan
    SHOW_HEADERS.count
  end

  def find_profile_category(category_id:)
    categories.detect { |profile_category| profile_category.category_id == category_id }
  end

  def lowest_category_status
    return if categories.visible.none?

    category_statuses = categories.visible.map(&:status).uniq

    return 'to_be_checked' if category_statuses.include?('to_be_checked')
    return 'to_be_fixed' if category_statuses.include?('to_be_fixed')
    return 'to_be_reviewed' if category_statuses.include?('to_be_reviewed')
    return 'to_be_submitted' if category_statuses.include?('to_be_submitted')

    category_statuses.first
  end

  def previous_state
    lowest_cat = categories.visible.detect { |cat| cat.status == lowest_category_status }

    lowest_cat&.history_events&.second_to_last_event_status || 'to_be_checked'
  end

  private

  def create_url(customer)
    h.customer_profile_index_path(customer_id: customer)
  end

  def update_url(customer)
    h.customer_profile_path(customer_id: customer, id: model)
  end
end
