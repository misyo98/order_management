class ColumnDecorator < Draper::Decorator
  FORBIDDEN_COLUMNS = %w(email phone).freeze
  SORTABLE_COLUMNS  = %w(delivery_appointment_date_field occasion_date_field date_entered_state).freeze
  SORTING_KEYS = { delivery_appointment_date_field: :delivery_appointment_date,
                   occasion_date_field: :occasion_date,
                   date_entered_state: :state_entered_date  }.freeze

  delegate_all

  def update_path
    h.column_path(id)
  end

  def invisible
    !visible
  end

  def not_for_outfitters?(user)
    (user.outfitter? || user.senior_outfitter?) && name.in?(FORBIDDEN_COLUMNS)
  end

  def tailors_approved_to_see_it
    user.tailor? && name.in?(ALLOWED_COLUMNS)
  end

  def sortable_state
    return false unless name.in?(SORTABLE_COLUMNS)

    sorting_column_name
  end

  private

  def sorting_column_name
    SORTING_KEYS[name.to_sym]
  end
end
