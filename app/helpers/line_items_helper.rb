module LineItemsHelper
  FORM_GROUP = 'form-group'.freeze
  INPUT_CLASS = 'form-control'.freeze
  DEFAULT_BTN_CLASSES = %w(btn btn-s view_link member_link batch-state-trigger margin-btm state-button).freeze
  DEFAULT_EXTRA_BTN_CLASSES = %w(btn btn-s view_link member_link margin-btm state-button batch-state-trigger).freeze
  BATCH_UPDATEABLE = %i(courier_company alteration_tailor location_of_sale sales_person outbound_tracking_number).freeze
  ERROR_FIELDS_INFO = {
    manufacturer_order_number: {
      field: :m_order_number
    },
    manufacturer: {
      field: :manufacturer, input_type: :select, helper_name: :manufacturer_for_select
    },
    courier_company: {
      field: :courier_company_id, input_type: :select, helper_name: :courier_company_for_select
    },
    alteration_tailor: {
      field: :alteration_tailor_id, input_type: :select, helper_name: :alteration_tailor_for_select
    },
    location_of_sale: {
      field: :sales_location_id, input_type: :select, helper_name: :sales_locations_for_select
    },
    sales_person: {
      field: :sales_person_id, input_type: :select, helper_name: :sales_persons_for_select
    },
    vat_export: {
      field: :vat_export, input_type: :checkbox
    },
  }.with_indifferent_access.freeze

  def self.line_item_scope_states(scopes:)
    result = {}
    li_scope_states = LineItem::STATE_QUEUES.keys.product([[]]).to_h
    scopes.each do |scope|
      scope.states.reject(&:blank?).each do |state|
        if result[state.to_sym].blank?
          result[state.to_sym] = [scope.label]
        else
          result[state.to_sym] << scope.label
        end
      end
    end

    result.merge!(li_scope_states) { |key, v1, v2| v1 }
  end

  def input_for_error(key)
    content_tag(:div, class: FORM_GROUP) do
      concat(label_tag key&.to_sym)
      concat(input_by_key(key))
    end
  end

  def input_by_key(key)
    input_info = ERROR_FIELDS_INFO[key]
    if input_info
      case input_info[:input_type]
      when :select
        select_tag input_info[:field],
          options_for_select(method(input_info[:helper_name]).call),
          class: INPUT_CLASS
      when :checkbox
        check_box_tag input_info[:field], false, false, class: INPUT_CLASS
      else
        text_field_tag input_info.dig(:field) || key, nil, class: INPUT_CLASS
      end
    else
      text_field_tag key, nil, class: INPUT_CLASS
    end
  end

  def can_be_batch_updated?(key)
    key.in? BATCH_UPDATEABLE
  end

  def courier_company_for_select
    CourierCompany.pluck(:name, :id)
  end
  
  def manufacturer_for_select
    LineItem::MANUFACTURERS.map { |key, value| [value, key] }
  end

  def alteration_tailor_for_select
    AlterationTailor.pluck(:name, :id)
  end

  def sales_locations_for_select
    SalesLocation.pluck(:name, :id)
  end

  def sales_persons_for_select
    User.pluck(:id, :first_name, :last_name)
        .map { |array| ["#{array[1]} #{array[2]}", array[0]] }
  end

  def state_button_classes(event:)
    DEFAULT_BTN_CLASSES.dup << event.to_s.dasherize
  end

  def extra_button_classes(event:)
    DEFAULT_EXTRA_BTN_CLASSES.dup << event.to_s.dasherize
  end
end
