class LineItemDecorator < Draper::Decorator
  delegate_all

  STATE_EVENT_BUTTONS = {
    'new'                           => ['wait', 'trigger_manufacturing'],
    'waiting_for_confirmation'      => ['trigger_manufacturing'],
    'submitted_profile'             => ['manufacturer_order_created'],
    'confirmed_profile'             => ['manufacturer_order_created'],
    'manufacturer_order_created'    => ['fabric_ordered'],
    'fabric_ordered'                => ['fabric_received'],
    'fabric_received'               => ['item_submitted'],
    'fit_confirmed'                 => ['trigger_manufacturing'],
    'item_out_of_stock'             => ['oos_resolved'],
    'inbounding'                    => ['at_office', 'prepare_shipment'],
    'partial_at_office'             => ['prepare_shipment', 'send_delivery_appt_email', 'wait_for_other_items'],
    'last_at_office'                => ['prepare_shipment', 'send_delivery_appt_email'],
    'single_at_office'              => ['prepare_shipment', 'send_delivery_appt_email'],
    'waiting_for_items'             => ['prepare_shipment', 'send_delivery_appt_email'],
    'waiting_for_items_alteration'  => ['prepare_shipment', 'send_delivery_appt_email'],
    'shipment_preparation'          => ['ship_items'],
    'delivery_email_sent'           => ['delivery_arranged'],
    'delivery_arranged'             => ['fit_confirmed_completed', 'back_to_delivery_email_sent', 'wait_for_other_items_from_alteration'],
    'shipped_unsubmitted'           => [''],
    'shipped_waiting_confirmation'  => ['fit_confirmed_completed', 'alteration_appointment_arranged'],
    'shipped_confirmed'             => ['completed', 'alteration_appointment_arranged'],
    'alteration_requested'          => ['sent_to_alterations_tailor'],
    'being_altered'                 => ['back_from_alteration'],
    'remake_requested'              => ['']
  }.freeze

  GIFT_STATE_EVENT_BUTTONS = {
    'new'                           => ['prepare_shipment', 'completed', 'wait_for_other_items'],
    'waiting_for_items'             => ['prepare_shipment', 'send_delivery_appt_email', 'completed'],
    'shipment_preparation'          => ['ship_items'],
    'shipped_confirmed'             => ['completed'],
  }.freeze

  REQUIRED_ACTIONS = {
    'payment_pending'               => ['Chase Payment'],
    'new'                           => ['Wait', 'Trigger Manufacturing'],
    'new_to_be_measured'            => [''],
    'waiting_for_confirmation'      => ['Wait'],
    'no_measurement_profile'        => ['Create measurement profile'],
    'to_be_checked_profile'         => ['Check measurement profile'],
    'to_be_fixed_profile'           => ['Fix measurement profile'],
    'to_be_reviewed_profile'        => ['Review measurement profile'],
    'to_be_submitted_profile'       => ['Check & submit measurement profile'],
    'submitted_profile'             => ['Create manufacturer order'],
    'confirmed_profile'             => ['Create manufacturer order'],
    'manufacturer_order_created'    => ['Order fabric'],
    'fabric_ordered'                => ['Wait for fabric'],
    'fabric_received'               => ['Submit item'],
    'item_out_of_stock'             => ['OOS - Resolve'],
    'manufacturing'                 => [''],
    'fit_confirmed'                 => ['Trigger'],
    'inbound_shipping'              => [''],
    'inbounding'                    => [''],
    'partial_at_office'             => ['Wait', 'Ship items', 'Arrange delivery'],
    'last_at_office'                => ['Ship items', 'Arrange delivery (several items)'],
    'single_at_office'              => ['Ship items', 'Arrange delivery'],
    'waiting_for_items'             => ['Wait for other items'],
    'waiting_for_items_alteration'  => ['Wait for other items (Alteration / Remake)'],
    'delivery_email_sent'           => ['Delivery email sent - Arrange delivery date'],
    'delivery_arranged'             => ['Wait, delivery arranged'],
    'shipped_unsubmitted'           => ['Submit measurement profile'],
    'shipped_waiting_confirmation'  => ['Get fit confirmation'],
    'shipped_confirmed'             => [''],
    'shipment_preparation'          => ['Ship item'],
    'alteration_appt_arranged'      => ['Alteration appointment arranged'],
    'alteration_requested'          => [''],
    'being_altered'                 => [''],
    'remake_requested'              => [''],
    'remade'                        => [''],
    'completed'                     => ['Completed'],
    'cancelled'                     => ['Cancelled'],
    'refunded'                      => ['Refunded'],
    'deleted_item'                  => ['Deleted']
  }.freeze

  PRODUCT_CATEGORIES = {
    'JACKETS' => 'J',
    'SUITS' => 'SU',
    'TROUSERS' => 'P',
    'WAISTCOATS' => 'W',
    'CHINOS' => 'C'
  }.freeze

  SALES_LOCATION = {
    'Duxton Showroom' => 'SIN',
    'Bond Street' => 'BND',
    'City Showroom' => 'CTY'
  }.freeze

  EXTRA_STATE_BUTTONS = {
    'delivery_arranged'             => ['open_alteration_form'],
    'delivery_email_sent'           => ['resend_delivery_email', 'book_delivery'],
    'alteration_appt_arranged'      => ['open_alteration_form'],
    'remake_requested'              => ['remake_approved'],
    'completed'                     => ['open_alteration_form']
  }.freeze

  SPECIAL_CUSTOMIZATIONS = {
    'Jacket Front' => {
      'Single Breasted - Three Buttons' => 'SB3B',
      'Double Breasted - Six Buttons'   => 'DB6B'
    },
    'Vents' => {
      'Centre Vent' => 'CentreV'
    },
    'Pant Front' => {
      'One Pleat'     => 'Pleat',
      'Double Pleats' => 'Pleat'
    },
    'Waistcoat Front' => {
      'Double Breasted - 6 Buttons' => 'DB WC',
      'Double Breasted - 8 Buttons' => 'DB WC'
    }
  }.freeze

  FABRIC_METAS = %w(Fabric\ Code Fabric\ Selection Fabric).freeze
  DEFAULT_BTN_CLASSES = %w(btn btn-s view_link member_link state-trigger margin-btm state-button).freeze
  DEFAULT_EXTRA_BTN_CLASSES = %w(btn btn-s view_link member_link margin-btm state-button).freeze
  CANVAS_META_KEY = 'Construction'.freeze
  CANVAS_PATTERNS = %w(Fused Half Full).freeze
  SUIT_FIT_META_KEY = 'Suit Fitting'.freeze
  SHIRT_FIT_META_KEY = 'Shirt Fit'.freeze
  SG_CURRENCY = 'SGD'.freeze
  FIT_META_KEYS = [SUIT_FIT_META_KEY, SHIRT_FIT_META_KEY].freeze
  DELAYED_STATE = 'delayed'.freeze
  CUSTOM_MEASURED_STATE = 'custom-measured'.freeze
  LATE_DELIVERY_STATE = 'late-delivery'.freeze
  SHIPPED_FIT_NOT_CONFIRMED_EVENT = 'shipped_fit_not_confirmed'.freeze
  PREPARE_SHIPMENT_EVENT = 'prepare_shipment'.freeze
  COMPLETED_EVENT = 'completed'.freeze
  WAIT_FOR_OTHER_ITEMS_EVENT = 'wait_for_other_items'.freeze
  HOLD_EVENT = 'hold'.freeze
  MEASURED = 'measured'.freeze
  JOIN_COMMA = ', '.freeze
  FABRIC_BRAND_KEY = 'Fabric Brand'.freeze
  CUSTOMER_TYPE_REPEAT = 'Repeat'.freeze
  CUSTOMER_TYPE_NEW = 'New'.freeze

  def status
    if manual_changes_tab?
      h.select_tag(:state, h.options_for_select(REQUIRED_ACTIONS.map { |state_event| [state_event[0].humanize, state_event[0]] }, model.state),
        class: 'item-state-select', data: { url: h.update_state_line_item_path(model), default: state })
    else
      h.link_to h.line_item_logged_events_path(line_item_id: id), remote: true do
        h.content_tag(:span, global_state, class: 'label flat-label-info trigger-state-history')
      end
    end
  end

  def allowed_state_event_links(with_copy_button: false)
    state_buttons = []

    state_buttons << copy_button if with_copy_button
    state_buttons << completed_gift_item_button if gift_category? && waiting_for_items?
    state_buttons << state_event_buttons
    state_buttons << shipped_fit_not_confirmed_button if delivery_arranged?
    state_buttons << to_be_measured_button if new? && (h.current_user.admin? || h.current_user.ops?)
    state_buttons << measured_button if new_to_be_measured? && (h.current_user.admin? || h.current_user.ops?)
    state_buttons << state_extra_buttons
    state_buttons << admins_event_buttons if (h.current_user.admin? || h.current_user.ops?)

    if gift_category? && new?
      state_buttons.clear
      state_buttons << prepare_shipment_gift_item_button
      state_buttons << completed_gift_item_button
      state_buttons << wait_gift_item_button
      state_buttons << admins_event_buttons if (h.current_user.admin? || h.current_user.ops?)
    end

    if tailor_user? && !state.in?(LineItem::STATES_EDITABLE_BY_TAILORS)
      state_buttons.clear
    end

    h.content_tag :span do
      state_buttons.flatten.join(' ').html_safe
    end.html_safe
  end

  def required_action
    return unless state
    REQUIRED_ACTIONS[state].join(' or ')
  end

  def comment
    if tailor_user?
      comment_field
    else
      h.content_tag(:span, class: 'far fa-edit', 'aria-hidden': true, id: "#{id}-comment") do
        h.best_in_place model, :comment_field, activator: "##{id}-comment", html_attrs: { readonly: h.current_user.tailor? }
      end.html_safe
    end
  end

  def order_comment_field
    if tailor_user?
      comment
    else
      h.content_tag(:span, class: 'glyphicon glyphicon-pencil', 'aria-hidden': true, id: "#{id}-order-comment") do
        h.best_in_place order, :comment, activator: "##{id}-order-comment", html_attrs: { readonly: h.current_user.tailor? }
      end.html_safe
    end
  end

  def order_number_field
    h.link_to order_number, h.order_path(order_id, scope: h.params[:scope]), remote: true
  end

  def order_total
    order_total_converted
  end

  def sales_person_field
    if h.current_user.can?(:edit_sales_person, LineItem)
      h.content_tag(:span, class: 'far fa-edit', 'aria-hidden': true, id: "#{id}-sales-person") do
        h.best_in_place model, :sales_person_id, as: :select, collection: h.assigns['sales_persons'], activator: "##{id}-sales-person"
      end.html_safe
    else
      sales_person&.full_name
    end
  end

  def location_of_sale
    if tailor_user?
      model.sales_location_name
    else
      h.content_tag(:span, class: 'far fa-edit', 'aria-hidden': true, id: "#{id}-sales-location") do
        h.best_in_place model, :sales_location_id, as: :select, collection: h.assigns['sales_locations'], activator: "##{id}-sales-location"
      end.html_safe
    end
  end

  def measurement_status
    return n_a_category_html unless order&.customer&.profile
    categories = order.customer.profile.categories.select { |profile_category| profile_category.category_name.in? local_category }
    return n_a_category_html if categories.empty?
    form_category_html(categories: categories)
  end

  def fabric_code
    h.content_tag(:span, class: 'far fa-edit', 'aria-hidden': true, id: "#{id}-fabric-code") do
      h.best_in_place model, :fabric_code_value, activator: "##{id}-fabric-code"
    end.html_safe
  end

  def manufacturer_fabric_code
    fabric&.manufacturer_fabric_code
  end

  def fabric_type
    fabric&.fabric_type&.dasherize&.humanize
  end

  def fabric_status
    h.content_tag(:span, class: 'far fa-edit', 'aria-hidden': true, id: "#{id}-fabric-status") do
      h.best_in_place model, :fabric_state, as: :select,
        collection: LineItem::FABRIC_STATUSES, data: { url: h.refresh_state_line_item_path(id) },
        url: h.trigger_fabric_state_line_item_path(id), activator: "##{id}-fabric-status"
    end.html_safe
  end

  def fabric_ordered_date_field
    I18n.l(fabric_ordered_date, format: :order_date) if fabric_ordered_date
  end

  def manufacturer_order_status
    h.content_tag(:span, class: 'far fa-edit', 'aria-hidden': true, id: "#{id}-order-status") do
      h.best_in_place model, :m_order_status, as: :select, collection: LineItem::RC_STATES, activator: "##{id}-order-status"
    end.html_safe
  end

  def manufacturer_order_number(prefix = nil)
    if tailor_user?
      m_order_number
    else
      h.content_tag(:span, class: 'far fa-edit', 'aria-hidden': true, id: "#{prefix}-#{id}-order-number") do
        h.best_in_place model, :m_order_number, data: { "manufacturer-order-number-id" => id },
        activator: "##{prefix}-#{id}-order-number", html_attrs: { readonly: h.current_user.tailor? }
      end.html_safe
    end
  end

  def inbound_tracking_number
    h.content_tag(:span, class: 'far fa-edit', 'aria-hidden': true, id: "#{id}-inbound-tracking-number") do
      h.best_in_place model, :tracking_number, activator: "##{id}-inbound-tracking-number"
    end.html_safe
  end

  def inbound_shipped_date
    shipped_date
  end

  def inbound_shipment_received_date
    shipment_received_date
  end

  def further_order_items_in_progress?
    other_items_in_progress? ? 'YES' : 'NO'
  end

  def next_appointment
    next_appointment_date
  end

  def wc_status
    order_status
  end

  def first_name
    order_billing_first_name
  end

  def last_name
    order_billing_last_name
  end

  def country
    order_shipping_country
  end

  def email
    order_billing_email
  end

  def phone
    order_billing_phone
  end

  def customer
    h.link_to order_customer_id, h.customer_path(order_customer_id)
  end

  def items_in_order
    order_total_line_items_quantity
  end

  def currency
    order_currency
  end

  def list_price
    subtotal.to_f / 100
  end

  def paid_price
    total.to_f / 100
  end

  def order_total_converted
    order.total.to_f / 100
  end

  def category
    product_category&.gsub('MADE-TO-MEASURE ', '')
  end

  def canvas
    return @canvas if @canvas
    key = meta.find { |meta_hash| meta_hash['key'] == CANVAS_META_KEY }
    return nil unless key
    @canvas ||= scrape_canvas(field: key['value'])
  end

  def alteration_tailor
    h.content_tag(:span, class: 'far fa-edit', 'aria-hidden': true, id: "#{id}-alter-tailor") do
      h.best_in_place model, :alteration_tailor_id, as: :select, collection: h.assigns['tailors'], activator: "##{id}-alter-tailor"
    end.html_safe
  end

  def courier_company
    h.content_tag(:span, class: 'far fa-edit', 'aria-hidden': true, id: "#{id}-courier-company") do
      h.best_in_place model, :courier_company_id, as: :select, collection: h.assigns['couriers'], activator: "##{id}-courier-company"
    end.html_safe
  end

  def outbound_tracking_number
    h.content_tag(:span, class: 'far fa-edit', 'aria-hidden': true, id: "#{id}-out-tracking-number") do
      h.best_in_place model, :outbound_tracking_number, activator: "##{id}-out-tracking-number"
    end.html_safe
  end

  def is_remake
    "#{h.content_tag(:span, 'REMAKE', class: 'label label-danger')}".html_safe if remake
  end

  def shipping_company
    order_shipping_company
  end

  def shipping_address_1
    order_shipping_address_1
  end

  def shipping_address_2
    order_shipping_address_2
  end

  def shipping_city
    order_shipping_city
  end

  def shipping_state
    order_shipping_state
  end

  def shipping_postcode
    order_shipping_postcode
  end

  def shipping_first_name
    order_shipping_first_name
  end

  def shipping_last_name
    order_shipping_last_name
  end

  def shipping_country
    order_shipping_country
  end

  def requested_completion_date
    if tailor_user?
      completion_date
    else
      h.content_tag(:span, class: 'far fa-edit', 'aria-hidden': true, id: "#{id}-completion-date") do
        h.best_in_place model, :completion_date, as: :date, activator: "##{id}-completion-date"
      end.html_safe
    end
  end

  def refunded_amount
    amount_refunded
  end

  def suit_fitting
    key = meta.find { |meta_hash| meta_hash['key'] == SUIT_FIT_META_KEY }
    key&.dig('value')
  end

  def shirt_fit
    key = meta.find { |meta_hash| meta_hash['key'] == SHIRT_FIT_META_KEY }
    key&.dig('value')
  end

  def to_be_shipped_date
    h.content_tag(:span, class: 'far fa-edit', 'aria-hidden': true, id: "#{id}-to-be-shipped") do
      h.best_in_place model, :to_be_shipped, as: :date, activator: "##{id}-to-be-shipped"
    end.html_safe
  end

  def urgent_field
    urgent? ? 'YES' : ''
  end

  def sent_to_alteration_date_field
    if tailor_user?
      sent_to_alteration_date
    else
      h.content_tag(:span, class: 'far fa-edit', 'aria-hidden': true, id: "#{id}-sent-to-alteration-date") do
        h.best_in_place model, :sent_to_alteration_date, as: :date, activator: "##{id}-sent-to-alteration-date"
      end.html_safe
    end
  end

  def date_entered_state
    date = state_entered_date || created_at

    h.l(date, format: :order_date)
  end

  def last_email_sent_date
    date = emails.last&.created_at

    h.l(date, format: :order_date) if date
  end

  def delivery_appointment_date_field
    h.l(delivery_appointment_date, format: :order_date) if delivery_appointment_date
  end

  def delivery_method_post_alteration
    if tailor_user?
      delivery_method&.humanize
    else
      h.content_tag(:span, class: 'far fa-edit', 'aria-hidden': true, id: "#{id}-delivery-method-post-alteration") do
        h.best_in_place model, :delivery_method, as: :select, collection: LineItem::DELIVERY_METHODS,
        activator: "##{id}-delivery-method-post-alteration", html_attrs: { disabled: h.current_user.tailor? }
      end.html_safe
    end
  end

  def estimated_delivery_date
    @estimated_delivery_date ||=
      if expected_delivery_time && state_entered_date
        I18n.l(state_entered_date + expected_delivery_time.days, format: :order_date)
      end
  end

  def deduction_sales_amount
    if h.current_user.can?(:deduct_sales_person, LineItem)
      h.content_tag(:span, class: 'far fa-edit', 'aria-hidden': true, id: "#{id}-dedaction-sales-amount") do
        h.best_in_place model, :deduction_sales, activator: "##{id}-dedaction-sales-amount"
      end.html_safe
    else
      deduction_sales
    end
  end

  def deduction_sales_person_field
    if h.current_user.can?(:deduct_sales_person, LineItem)
      h.content_tag(:span, class: 'far fa-edit', 'aria-hidden': true, id: "#{id}-deduction-sales-person") do
        h.best_in_place model, :deduction_sales_person_id, as: :select, collection: h.assigns['sales_persons'], activator: "##{id}-deduction-sales-person"
      end.html_safe
    else
      deduction_sales_person&.full_name
    end
  end

  def deduction_sales_comment_field
    if h.current_user.can?(:deduct_sales_person, LineItem)
      h.content_tag(:span, class: 'far fa-edit', 'aria-hidden': true, id: "#{id}-dedaction-sales-comment") do
        h.best_in_place model, :deduction_sales_comment, activator: "##{id}-dedaction-sales-comment"
      end.html_safe
    else
      deduction_sales_comment
    end
  end

  def deduction_ops_amount
    if h.current_user.can?(:deduct_ops_person, LineItem)
      h.content_tag(:span, class: 'far fa-edit', 'aria-hidden': true, id: "#{id}-dedaction-ops-amount") do
        h.best_in_place model, :deduction_ops, activator: "##{id}-dedaction-ops-amount"
      end.html_safe
    else
      deduction_ops
    end
  end

  def deduction_ops_person_field
    if h.current_user.can?(:deduct_ops_person, LineItem)
      h.content_tag(:span, class: 'far fa-edit', 'aria-hidden': true, id: "#{id}-deduction-ops-person") do
        h.best_in_place model, :deduction_ops_person_id, as: :select, collection: h.assigns['ops_people'], activator: "##{id}-deduction-ops-person"
      end.html_safe
    else
      deduction_ops_person&.full_name
    end
  end

  def deduction_ops_comment_field
    if h.current_user.can?(:deduct_ops_person, LineItem)
      h.content_tag(:span, class: 'far fa-edit', 'aria-hidden': true, id: "#{id}-dedaction-ops-comment") do
        h.best_in_place model, :deduction_ops_comment, activator: "##{id}-dedaction-ops-comment"
      end.html_safe
    else
      deduction_ops_comment
    end
  end

  def non_altered_items_field
    AlterationSummary::NON_ALTERED_ITEMS.key(non_altered_items.to_sym) if non_altered_items
  end

  def garment_fit
    meta.each { |meta_hash| return meta_hash['value'] if meta_hash['key'].in?(FIT_META_KEYS) }
    nil
  end

  def occasion_date_field
    if tailor_user?
      occasion_date
    else
      h.content_tag(:span, class: 'far fa-edit', 'aria-hidden': true, id: "#{id}-occasion-date") do
        h.best_in_place model, :occasion_date, as: :date, activator: "##{id}-occasion-date"
      end.html_safe
    end
  end

  def manufacturer
    if tailor_user?
      LineItem::MANUFACTURERS[model.manufacturer.to_sym]
    else
      h.content_tag(:span, class: 'far fa-edit', 'aria-hidden': true, id: "#{id}-manufacturer") do
        h.best_in_place model, :manufacturer, as: :select, collection: LineItem::MANUFACTURERS, activator: "##{id}-manufacturer"
      end.html_safe
    end
  end

  def resolve_item_color_class
    if late_delivery?
      LATE_DELIVERY_STATE
    elsif is_delayed?
      DELAYED_STATE
    elsif order_customer&.profile&.custom_measured?
      CUSTOM_MEASURED_STATE
    end
  end

  def customer_type
    if order&.first_order?
      CUSTOMER_TYPE_NEW
    else
      CUSTOMER_TYPE_REPEAT
    end
  end

  def alteration_costs
    alteration_summaries.sum(:amount)
  end

  def customer_note
    order_note
  end

  def reminder_emails
    h.content_tag(:span, class: 'far fa-edit', 'aria-hidden': true, id: "#{id}-reminder-emails") do
      h.best_in_place model, :send_reminders, as: :checkbox, collection: {'false' => 'OFF', 'true' => "ON"},
      activator: "##{id}-reminder-emails"
    end.html_safe
  end

  def coupons
    order_coupon_lines.map{ |o| o['code'] }.join(JOIN_COMMA)
  end

  def fabric_brand
    meta.find { |meta_hash| meta_hash['key'] == FABRIC_BRAND_KEY }&.dig('value')
  end

  def self_measured
    order.customer&.profile&.custom_measured? ? 'YES' : 'NO'
  end

  def customer_acquisition_channel
    order&.customer&.acquisition_channel
  end

  def refund_reason
    last_refund = refunds.last

    return unless last_refund
    last_refund.decorate.refund_reason
  end

  def vat_export_field
    h.content_tag(:span, class: 'far fa-edit', 'aria-hidden': true, id: "#{id}-vat-export") do
      h.best_in_place model, :vat_export, as: :select, collection: { false => 'NO', true => 'YES' },
      activator: "##{id}-vat-export"
    end.html_safe
  end

  def remake_category_field
    remake_category&.join(JOIN_COMMA)
  end

  def fabric_tracking_number
    h.content_tag(:span, class: 'far fa-edit', 'aria-hidden': true, id: "#{id}-fabric-tracking-number") do
      h.best_in_place model, :fabric_tracking_number, activator: "##{id}-fabric-tracking-number"
    end.html_safe
  end

  def comment_for_tailor
    if tailor_user?
      model.comment_for_tailor
    else
      h.content_tag(:span, class: 'far fa-edit', 'aria-hidden': true, id: "#{id}-comment_for_tailor") do
        h.best_in_place model, :comment_for_tailor, activator: "##{id}-comment_for_tailor"
      end.html_safe
    end
  end

  def tags_field
    h.render 'admin/line_item/tags', tags: tags, line_item: model
  end

  def meters_required_field
    case
      when category == 'SUITS'                              then 3.5
      when category == 'JACKETS'                            then 2
      when category == 'TROUSERS'                           then 1.6
      when category == 'CHINOS'                             then 1.6
      when category == 'WAISTCOATS' && with_suit_fabric?    then 1.6
      when category == 'WAISTCOATS' && with_lining_fabric?  then 1
    end
  end

  def warning_extra_fabric
    return 'NO' unless order.customer&.profile

    extra_fabric_garments =
      Measurement.joins(category_param: :param).where(profile_id: order.customer&.profile_id).where(
        Param.arel_table[:title].eq('Chest').and(Measurement.arel_table[:final_garment].gt(50))
          .or(Param.arel_table[:title].eq('Waistcoat Chest').and(Measurement.arel_table[:final_garment].gt(50)))
          .or(Param.arel_table[:title].eq('Hip').and(Measurement.arel_table[:final_garment].gt(50)))
          .or(Param.arel_table[:title].eq('Thigh').and(Measurement.arel_table[:final_garment].gt(29)))
          .or(Param.arel_table[:title].eq('Height (cm)').and(Measurement.arel_table[:final_garment].gt(195)))
      ).limit(1)

    if extra_fabric_garments.any?
      'YES'
    else
      'NO'
    end
  end

  def m_order_number_not_made
    if m_order_number.blank?
      "ES#{SALES_LOCATION[sales_location_name]}_#{order_id}_#{PRODUCT_CATEGORIES[category]}_#{item_serial_number}"
    end
  end

  def ordered_fabric
    if tailor_user?
      model.ordered_fabric ? 'Yes' : 'No'
    else
      h.content_tag(:span, class: 'far fa-edit', 'aria-hidden': true, id: "#{id}-ordered_fabric") do
        h.best_in_place model, :ordered_fabric, as: :select, collection: { nil: '', false: 'NO', true: 'YES' },
        activator: "##{id}-ordered_fabric"
      end.html_safe
    end
  end

  def special_customizations_field
    special = maybe_special_customizations

    if special.any?
      h.content_tag(:div, special.join(', '), class: 'special-customizations')
    else
      nil
    end
  end

  def maybe_special_customizations
    meta_hash = meta.each_with_object({}) { |m, hash| hash[m['key']] = m['value'] }
    meta_hash.each_with_object([]) do |(key, value), array|
      if SPECIAL_CUSTOMIZATIONS.dig(key, value).present?
        array << SPECIAL_CUSTOMIZATIONS[key][value]
      end
    end
  end

  def maybe_days_in_state_field
    h.distance_of_time_in_words(Time.now, state_entered_date) if state_entered_date
  end

  def remind_to_get_measured
    unless h.current_user.admin? || h.current_user.ops?
      model.remind_to_get_measured
    else
      h.content_tag(:span, class: 'far fa-edit', 'aria-hidden': true, id: "#{id}-remind-to-get-measured") do
        h.best_in_place model, :remind_to_get_measured, as: :date, activator: "##{id}-remind-to-get-measured"
      end.html_safe
    end
  end

  private

  def form_category_html(categories:)
    categories.inject([]) { |array, profile_category| array << category_html(category: profile_category); array }.join('</br>').html_safe
  end

  def category_html(category:)
    "#{category.category_name}:</br> #{h.content_tag(:span, category.status, class: CustomerDecorator::STATUS_LABELS[category.status])}"
  end

  def n_a_category_html
    "#{h.content_tag(:span, 'n/a', class: 'label label-default')}".html_safe
  end

  def copy_button
    h.content_tag(:span, h.link_to(copied? ? 'Copied!' : 'Copy to clipboard', h.mark_as_copied_line_item_path(id), method: :patch,
      class: DEFAULT_BTN_CLASSES.dup << 'copy', remote: true,
      data: { clipboard_target: "#copy-table-container-#{id}" }))
  end

  def state_button_classes(event:)
    DEFAULT_BTN_CLASSES.dup << event.to_s.dasherize
  end

  def extra_button_classes(event:)
    DEFAULT_EXTRA_BTN_CLASSES.dup << event.to_s.dasherize
  end

  def state_event_buttons
    if STATE_EVENT_BUTTONS[state]
      STATE_EVENT_BUTTONS[state].inject([]) { |array, event| array << state_button_html(event: event); array }
    end
  end

  def state_extra_buttons
    if EXTRA_STATE_BUTTONS[state]
      EXTRA_STATE_BUTTONS[state].inject([]) { |array, event| array << extra_button_html(event: event); array }
    end
  end

  def admins_event_buttons
    buttons = []
    buttons << state_button_html(event: 'cancel', data_attrs: {
      swal: true,
      swal_text: 'This action cancels orders'
    }) unless cancelled? || refunded? || remade?
    buttons << extra_button_html(event: 'refund') unless refunded? || remake || cancelled?
    buttons << delete_button_html if order.cancelled? && manual_changes_tab?
    buttons << delete_state_button_html unless deleted_item?
    buttons
  end

  def state_button_html(event:, data_attrs: {})
    h.content_tag(:span, h.link_to(event.humanize, 'javascript:;',
      class: state_button_classes(event: event),
      data: {
        url: h.trigger_state_line_item_path(model),
        'state-event' => event
      }.merge(data_attrs)))
  end

  def extra_button_html(event:)
    h.content_tag(:span, h.link_to(event.humanize, resolve_path(event: event)[:link],
                                   class: extra_button_classes(event: event),
                                   remote: resolve_path(event: event)[:remote],
                                   target: resolve_path(event: event)[:target]))
  end

  def delete_button_html
    h.content_tag(:span, h.link_to('Delete', 'javascript:;', class: extra_button_classes(event: 'delete'),
                                   data: { url: h.line_item_path(id), id: id }))
  end

  def delete_state_button_html
    h.content_tag(:span, h.link_to('Delete', h.trigger_state_line_item_path(id, state_event: 'delete_item'),
                                    method: :patch, remote: true, class: extra_button_classes(event: 'delete_item')))
  end

  def shipped_fit_not_confirmed_button
    if measurement_profile_unconfirmed?
      state_button_html(event: SHIPPED_FIT_NOT_CONFIRMED_EVENT)
    end
  end

  def prepare_shipment_gift_item_button
    if gift_category?
      state_button_html(event: PREPARE_SHIPMENT_EVENT )
    end
  end

  def completed_gift_item_button
    if gift_category?
      state_button_html(event: COMPLETED_EVENT )
    end
  end

  def wait_gift_item_button
    if gift_category?
      state_button_html(event: WAIT_FOR_OTHER_ITEMS_EVENT )
    end
  end

  def to_be_measured_button
    state_button_html(event: HOLD_EVENT)
  end

  def measured_button
    state_button_html(event: MEASURED)
  end

  def resolve_path(event:)
    case event
    when 'open_alteration_form'
      return error_link unless order.customer&.profile_id

      { link: h.edit_customer_profile_path(customer_id: order.customer_id, id: order.customer.profile_id, line_item_id: id),
        remote: false, target: nil }
    when 'remake_approved'
      { link: h.create_remake_line_item_path(id), remote: false, target: nil }
    when 'refund'
      { link: h.new_refund_line_item_path(id), remote: true, target: nil }
    when 'resend_delivery_email'
      { link: h.resend_delivery_email_line_item_path(id), remote: true, target: nil }
    when 'book_delivery'
      { link: "#{sales_location&.delivery_calendar_link}?order_token=#{order_customer&.token}",
        remote: false, target: '_blank' }
    end
  end

  def error_link
    { link: h.no_profile_message_line_item_path(id), remote: true }
  end

  def manual_changes_tab?
    h.params[:scope] == 'change_states'
  end

  def paid_date
    order_date.to_date
  end

  def scrape_canvas(field:)
    CANVAS_PATTERNS.each { |pattern| canvas = field.scan(pattern); return canvas.join if !canvas.empty? }
    nil
  end

  def expected_delivery_time
    return @expected_delivery_time if defined?(@expected_delivery_time)

    proper_timeline = context[:timelines].find { |timeline| timeline.state == state }

    return @expected_delivery_time = nil unless proper_timeline

    location_time = proper_timeline.sales_location_timelines.for_location(sales_location_id)&.expected_delivery_time

    @expected_delivery_time = location_time || resolve_country_delivery_time(proper_timeline)
  end

  def resolve_country_delivery_time(timeline)
    case currency
    when SG_CURRENCY
      timeline.expected_delivery_time_sg
    else
      timeline.expected_delivery_time_uk
    end
  end

  def late_delivery?
    return false unless estimated_delivery_date && occasion_date

    estimated_delivery_date.to_date > (occasion_date - 10.days)
  end

  def with_lining_fabric?
    meta.detect { |m| m.dig('value') == 'Back with Lining Fabric' }
  end

  def with_suit_fabric?
    meta.detect { |m| m.dig('value') == 'Back with Suit Fabric' }
  end

  def item_serial_number
    order.line_items.select { |item| item.decorate.category == category }.index(model) + 1 rescue 1
  end

  def tailor_user?
    h.current_user.tailor?
  end
end
