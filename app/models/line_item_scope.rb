class LineItemScope < ActiveRecord::Base
  VALIDATION_REGEXP = /\A[a-zA-Z0-9\s]*\z/.freeze
  # this always needs to be up-to-date for ActiveAdmin scopes to work
  TABLE_COLUMNS = %w(label order states).freeze

  WITHOUT_COUNT = %w(All\ Orders Completed).freeze

  serialize :states, Array
  serialize :visible_for, Array

  has_many  :columns, as: :columnable
  has_many  :line_item_scope_sales_locations
  has_many  :user_sales_locations, through: :line_item_scope_sales_locations, source: :sales_location
  has_many  :line_item_scope_sales_location_items
  has_many  :item_sales_locations, through: :line_item_scope_sales_location_items, source: :sales_location

  validates :label, format: { with: VALIDATION_REGEXP, message: :invalid_que }, uniqueness: true

  def visible_for_user?(user)
    if user_sales_location_ids.empty?
      user.role.in?(visible_for)
    elsif user.sales_locations.any?
      (user.sales_location_ids & user_sales_location_ids).any? && user.role.in?(visible_for)
    else
      user.role.in?(visible_for)
    end
  end
end
