# frozen_string_literal: true

module BookingTool
  class AppointmentDecorator < Draper::Decorator
    JOIN_SYMBOL = ', '
    YES = 'Yes'
    NO = 'No'
    BIP_OBJECT_PARAM = 'object Object'
    BLANK = '_blank'
    DATE_FORMAT = '%B %d, %Y %H:%M'
    LAST_PURCHASE_DATE_FORMAT = '%B %d, %Y'
    JOIN_BUTTONS_SYMBOL = ' '
    OUTDATED_CLASS = 'delayed'
    CREATE_LINK_PARAMS = '/new-user?token_user_registr=25-t8-er-62&user_registr_email='
    LOGIN_LINK_PARAMS = '/my-account?token_user_log_in=25-t8-er-62&user_log_in_email='
    WEBSITE_LINK = ENV['website'].freeze
    EDITSUITS_CREATE_LINK = WEBSITE_LINK + CREATE_LINK_PARAMS
    EDITSUITS_LOGIN_LINK = WEBSITE_LINK + LOGIN_LINK_PARAMS
    DEFAULT_BTN_CLASSES = %w(btn btn-s view_link member_link margin-btm state-button).freeze
    STATES_SHOWING_PROGRESS_OR_REJECTION = ['completed', 'alteration_requested', 'remake_requested', 'cancelled',
                                            'waiting_for_items_alteration', 'refunded', 'remade', 'deleted_item'].freeze
    OUTDATED_STATES = ['delivery_email_sent', 'delivery_arranged'].freeze
    REASONS = {
      no_show:'No show',
      invoiced: 'Invoiced',
      delivered: 'Delivery',
      other: 'Other (put a comment please)',
      browsing: 'Browsing - Non-wedding',
      wedding_browsing: 'Browsing - Wedding (please enter wedding date)'
    }.with_indifferent_access.freeze
    LOCATION = { 'sg' => 'Singapore', 'gb' => 'London' }.freeze
    DELETED_PARAM = '&deleted=true'.freeze

    delegate_all

    def time
      "#{self.start} - #{self.end}"
    end

    def existing_customer
      to_yes_or_no(customer.present?)
    end

    def maybe_order_comment
      customer&.orders&.last&.comment
    end

    def maybe_customer_link
      h.link_to customer.id, h.customer_path(customer) if customer
    end

    def maybe_acquisition_channel
      customer&.acquisition_channel || acquisition_channel
    end

    def maybe_last_purchase_date
      if customer
        "(#{customer.last_order_created_at&.strftime(LAST_PURCHASE_DATE_FORMAT)})"
      end
    end

    def previous_order_numbers
      if previous_orders
        order_ids = previous_orders.pluck(:number).last(5).join(JOIN_SYMBOL)

        h.content_tag(:span, h.link_to(order_ids, h.all_items_customer_path(customer), remote: true))
      end
    end

    def previous_outfitter
      previous_orders&.last&.line_items&.first&.sales_person&.full_name if previous_orders
    end

    def formatted_cancelled
      h.content_tag(:span, to_yes_or_no(cancelled), class: ['label', cancelled ? 'flat-label-fail' : 'flat-label-success'])
    end

    def formatted_purchased
      h.content_tag(:span, to_yes_or_no(purchased), class: ['label', purchased ? 'flat-label-success' : 'flat-label-fail'])
    end

    def formatted_active_booking
      h.content_tag(:span, to_yes_or_no(active_booking), class: ['label', active_booking ? 'flat-label-success' : 'flat-label-fail'])
    end

    def resolve_no_purchase_reason_field
      if needs_follow_up && !cancelled && !purchased
        no_purchase_reason_dropdown
      end
    end

    def comment_field
      h.content_tag(:span, class: 'far fa-edit', 'aria-hidden': true, id: "#{id}-follow-up-status") do
        h.best_in_place model, :follow_up_status, url: h.booking_tool_appointment_path(id: id),
                        param: User.new, activator: "##{id}-follow-up-status", inner_class: 'comment-field'
      end
    end

    def allocated_outfitter
      h.content_tag(:span, class: 'far fa-edit', 'aria-hidden': true, id: "#{id}-allocated-outfitter") do
        h.best_in_place model, :allocated_outfitter_id, url: h.booking_tool_appointment_path(id: id), as: :select,
                        collection: context[:sales_people], param: User.new, activator: "##{id}-allocated-outfitter"
      end
    end

    def wedding_date_field
      h.content_tag(:span, class: 'far fa-edit', 'aria-hidden': true, id: "#{id}-wedding-date-field") do
        h.best_in_place model, :wedding_date, url: h.booking_tool_appointment_path(id: id), as: :date,
                        param: User.new, activator: "##{id}-wedding-date-field"
      end
    end

    def outfitter_action_links
      [outfitter_remove_button, maybe_create_customer_button,
       maybe_customer_login_button, maybe_change_state_button, maybe_no_show_button, call_later_button].join(JOIN_BUTTONS_SYMBOL).html_safe
    end

    def ops_action_links
      [call_button, ops_remove_button, maybe_reschedule_button, call_later_button].join(JOIN_BUTTONS_SYMBOL).html_safe
    end

    def dropped_action_links
      [call_button, dropped_remove_button, book_appoinment_button, call_later_button].join(JOIN_BUTTONS_SYMBOL).html_safe
    end

    def required_action
      if cancelled || no_show_reason?
        'Call and try to reschedule or obtain reason for cancellation'
      elsif invoiced_reason?
        'Call up and ask if they need assistance'
      elsif other_reason?
        'See if needs call, otherwise remove from list'
      end
    end

    def call_count_with_date
      h.link_to "Count: #{call_count}, Last time called: #{formatted_last_called_date}",
                h.call_history_booking_tool_appointment_path(id), remote: true
    end

    def maybe_outfitters_outdated_class
      OUTDATED_CLASS if outfitter_update_required? || item_update_required?
    end

    def maybe_ops_outdated_class
      OUTDATED_CLASS if item_update_required?
    end

    REASONS.keys.each do |key|
      define_method("#{key}_reason?") { no_purchase_reason == key }
    end

    def city
      LOCATION[country]
    end

    def recent_order
      if purchased
        last_order = previous_orders&.order(created_at: :desc)&.first
        "#{last_order.total.to_f / 100} #{last_order.currency}" if last_order
      end
    end

    def outfitter_that_updated
      outfitter = context[:sales_people].find { |outfitter_id, outfitter_name| outfitter_id == order_tool_outfitter_id }
      outfitter&.last
    end

    def maybe_booking_history_link
      h.link_to 'History', h.booking_history_booking_tool_appointments_path(email: customer&.email ||email ), remote: true
    end

    def maybe_dropped_dates
      if dropped_events.count > 1
        h.link_to 'Dropped Dates', h.dropped_events_booking_tool_appointments_path(dropped_dates: dropped_events), remote: true
      else
        submitted
      end
    end

    private

    def customer
      @customer ||= Customer.find_by(email: email)
    end

    def to_yes_or_no(boolean_value)
      boolean_value ? YES : NO
    end

    def previous_orders
      @previous_orders ||= customer&.orders
    end

    def no_purchase_reason_dropdown
      h.content_tag(:span, class: 'far fa-edit purchase-reason-dropdown', 'aria-hidden': true, id: "#{id}-purchase-reason") do
        h.best_in_place model, :no_purchase_reason, url: h.booking_tool_appointment_path(id: id), as: :select,
                        collection: REASONS, param: User.new, activator: "##{id}-purchase-reason"
      end
    end

    def start_time
      return @start_time if defined?(@start_time)
      return if start.nil?
      appt_start = Time.parse(start)
      @start_time ||= DateTime.new(appt_date.year, appt_date.month, appt_date.day, appt_start.hour, appt_start.min, appt_start.sec)
    end

    def appt_date
      @appt_date ||= Time.parse(day)
    end

    def formatted_last_called_date
      return unless last_call_date
      Time.parse(last_call_date).strftime(DATE_FORMAT)
    end

    def item_update_required?
      @item_update_required ||= !needs_follow_up && !cancelled && customer && item_not_updated?
    end

    def outfitter_update_required?
      needs_follow_up && !cancelled && !purchased
    end

    def item_not_updated?
      @item_not_updated ||= customer.line_items.with_states(OUTDATED_STATES).any?
    end

    def appointment_started
      return false if start_time.nil?
      DateTime.now > start_time
    end

    def maybe_change_state_button
      if item_update_required?
        h.content_tag(:span, h.link_to('Change state', h.active_items_customer_path(customer), remote: true,
                                       class: DEFAULT_BTN_CLASSES + ['change-state']))
      end
    end

    def outfitter_remove_button
      h.content_tag(:span, h.link_to('Remove from list', 'javascript:;', class: DEFAULT_BTN_CLASSES + ['approve-changes'],
                     data: { api_url: h.booking_tool_appointment_path(id: id, removing: true, customer_id: customer&.id),
                             outfitter_id: h.current_user.id, admin_user: h.current_user.admin? }))
    end

    def dropped_remove_button
      h.content_tag(:span, h.link_to('Remove from list',
                                     h.removed_by_ops_booking_tool_appointment_path(id: id, BIP_OBJECT_PARAM => { removed_from_dropped: 1 }),
                                     method: :patch, remote: true, class: DEFAULT_BTN_CLASSES + ['remove']))
    end

    def maybe_create_customer_button
      return if customer

      h.content_tag(:span, h.link_to('Create acount', EDITSUITS_CREATE_LINK + email,
                                     class: DEFAULT_BTN_CLASSES + ['create-acc'], target: BLANK))
    end

    def maybe_customer_login_button
      return unless customer

      h.content_tag(:span, h.link_to('Customer Login', EDITSUITS_LOGIN_LINK + email,
                                     class: DEFAULT_BTN_CLASSES + ['login-acc'], target: BLANK))
    end

    def call_button
      h.content_tag(:span, h.link_to('Called', h.called_booking_tool_appointment_path(id), method: :patch, remote: true,
                                     class: DEFAULT_BTN_CLASSES + ['called']))
    end

    def ops_remove_button
      h.content_tag(:span, h.link_to('Remove from list',
                                     h.removed_by_ops_booking_tool_appointment_path(id: id,
                                                                                    BIP_OBJECT_PARAM => { removed_by_ops: 1 }),
                                     method: :patch, remote: true, class: DEFAULT_BTN_CLASSES + ['remove']))
    end

    def maybe_reschedule_button
      link = reschedule_link
      return unless link
      link += DELETED_PARAM if cancelled
      h.content_tag(:span, h.link_to('Reschedule', link, target: BLANK, class: DEFAULT_BTN_CLASSES + ['reschedule']))
    end

    def maybe_no_show_button
      return unless item_update_required?

      h.content_tag(:span, h.link_to('No show',
                                     h.no_show_booking_tool_appointment_path(id: id, customer_id: customer.id,
                                                                             BIP_OBJECT_PARAM => { updated_by_outfitter: 1 }),
                                     method: :patch, remote: true, class: DEFAULT_BTN_CLASSES + ['no-show']))
    end

    def book_appoinment_button
      return unless reschedule_link

      h.content_tag(:span, h.link_to('Book appointment', reschedule_link + DELETED_PARAM, target: BLANK, class: DEFAULT_BTN_CLASSES + ['reschedule']))
    end

    def call_later_button
      h.content_tag(:span, h.link_to('Call later', h.call_later_booking_tool_appointment_path(id), class: 'btn btn-primary', id: "#{id}", method: :get, remote: true))
    end
  end
end
