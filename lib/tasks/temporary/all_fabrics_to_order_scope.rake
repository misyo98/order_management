task all_fabrics_to_order_scope: :environment do
  scope = LineItemScope.find_or_create_by(label: 'All fabrics to order', order: 84, show_counter: true, visible_for: ['admin', 'ops'], custom_scope: 'all_fabrics_to_order')
  scope.save!

  raw_attributes = Column.line_items.pluck(:name, :order, :visible, :label)

  def assign_column_attributes(attributes:, scope_id:)
    columns = %i(name order visible label)
    attributes = [columns, attributes].transpose.to_h
    attributes.merge!(columnable_id: scope_id, columnable_type: 'LineItemScope')
  end

  formatted_attributes = raw_attributes.inject([]) { |array, attributes| array << assign_column_attributes(attributes: attributes, scope_id: scope.id); array }

  scope_columns = formatted_attributes.inject([]) { |array, attributes| array << Column.new(attributes); array }

  Column.import scope_columns

  scope.columns.find_or_create_by(name: 'meters_required_field', label: 'Meters required', order: 119)
  scope.columns.find_or_create_by(name: 'warning_extra_fabric', label: 'Warning: Extra Fabric', order: 120)
  scope.columns.find_or_create_by(name: 'm_order_number_not_made', label: 'Manufacturer Order Number (not made)', order: 121)

  puts 'Created columns for all_fabrics_to_order scope'
end
