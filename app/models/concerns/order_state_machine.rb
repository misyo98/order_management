module OrderStateMachine
  extend ActiveSupport::Concern

  included do
    state_machine initial: :payment_pending do
      audit_trail context: [:user_id, :tailor_id, :courier_id]

      #initial event for line items that are now available to work with
      event :chase_payment do
        transition payment_pending: :new
      end

      #waiting for fit confirmation
      event :wait do
        transition new: :fit_confirmed, if: :fit_confirmed?
        transition new: :waiting_for_confirmation
      end

      event :fit_confirmed do
        transition waiting_for_confirmation: :fit_confirmed
      end

      #TRIGGERED MANUFACTURING SECTION

      #Start manufacturing
      event :trigger_manufacturing do
        transition [:waiting_for_confirmation, :new, :remake_requested] => :no_measurement_profile, if: :no_measurement_profile?
        transition [:waiting_for_confirmation, :new, :remake_requested] => :to_be_checked_profile, if: :measurement_profile_to_be_checked?
        transition [:waiting_for_confirmation, :new, :remake_requested] => :to_be_fixed_profile, if: :measurement_profile_to_be_fixed?
        transition [:waiting_for_confirmation, :new, :remake_requested] => :to_be_reviewed_profile, if: :measurement_profile_to_be_reviewed?
        transition [:waiting_for_confirmation, :new, :remake_requested] => :to_be_submitted_profile, if: :measurement_profile_to_be_submitted?
        transition [:waiting_for_confirmation, :new, :remake_requested] => :submitted_profile
        transition fit_confirmed: :confirmed_profile
      end

      event :hold do
        transition new: :new_to_be_measured
      end

      event :measured do
        transition new_to_be_measured: :new
      end

      event :saved_to_be_reviewed do
        transition [:to_be_checked_profile, :to_be_fixed_profile] => :to_be_reviewed_profile
      end

      event :saved_to_be_submitted do
        transition [:to_be_checked_profile, :to_be_fixed_profile] => :to_be_submitted_profile
      end

      event :reviewed_not_ok do
        transition [:to_be_checked_profile, :to_be_submitted_profile, :to_be_reviewed_profile] => :to_be_fixed_profile
      end

      event :saved_to_be_checked do
        transition [:no_measurement_profile, :to_be_fixed_profile] => :to_be_checked_profile
      end

      #Check & submit measurement profile
      event :profile_submission do
        transition [:to_be_reviewed_profile, :to_be_submitted_profile] => :submitted_profile
      end

      #Create manufacturer order
      event :manufacturer_order_created do
        transition [:submitted_profile, :confirmed_profile] => :fabric_ordered, if: :ordered_fabric?
        transition [:submitted_profile, :confirmed_profile] => :fabric_received, if: :fabric_is_available?
        transition [:submitted_profile, :confirmed_profile] => :manufacturer_order_created
      end

      #Order fabric
      event :fabric_ordered do
        transition manufacturer_order_created: :fabric_received, if: :fabric_is_available?
        transition manufacturer_order_created: :fabric_ordered
      end

      #Wait for fabric
      event :fabric_received do
        transition fabric_ordered: :fabric_received
      end

      #Submit item
      event :item_submitted do
        transition fabric_received: :manufacturing
      end

      #Out of stock
      event :got_out_of_stock do
        transition [:manufacturer_order_created, :fabric_ordered, :fabric_received] => :item_out_of_stock
      end

      #Out Of Stock(OOS) Resolve
      event :oos_resolved do
        transition item_out_of_stock: :fabric_received
      end

      event :inbound_number_added do
        transition manufacturing: :inbound_shipping
      end

      event :inbounding do
        transition inbound_shipping: :inbounding
      end

      event :at_office do
        transition inbounding: :partial_at_office, if: :other_items_in_progress?
        transition inbounding: :last_at_office, if: :other_items_at_office?
        transition inbounding: :single_at_office
      end

      event :wait_for_other_items do
        transition new: :waiting_for_items, if: :gift_category?
        transition partial_at_office: :waiting_for_items
      end

      event :wait_for_other_items_from_alteration do
        transition delivery_arranged: :waiting_for_items_alteration
      end

      event :send_delivery_appt_email do
        transition [:partial_at_office, :last_at_office, :single_at_office, :waiting_for_items, :delivery_arranged, :waiting_for_items_alteration] => :delivery_email_sent
      end

      event :prepare_shipment do
        transition new: :shipment_preparation, if: :gift_category?
        transition [:partial_at_office, :last_at_office, :single_at_office, :waiting_for_items, :inbounding, :waiting_for_items_alteration, :delivery_email_sent] => :shipment_preparation
      end

      event :ship_items do
        transition shipment_preparation: :shipped_confirmed, if: :gift_category?
        transition shipment_preparation: :shipped_unsubmitted, if: :measurement_profile_to_be_reviewed?
        transition shipment_preparation: :shipped_unsubmitted, if: :measurement_profile_to_be_fixed?
        transition shipment_preparation: :shipped_unsubmitted, if: :measurement_profile_to_be_submitted?
        transition shipment_preparation: :shipped_waiting_confirmation, if: :measurement_profile_unconfirmed?
        transition shipment_preparation: :shipped_confirmed
      end

      event :fit_confirmed_completed do
        transition [:delivery_arranged, :shipped_waiting_confirmation] => :completed
      end

      event :completed do
        transition new: :completed, if: :gift_category?
        transition waiting_for_items: :completed, if: :gift_category?
        transition shipped_confirmed: :completed
      end

      event :alteration_appointment_arranged do
        transition [:shipped_confirmed, :shipped_waiting_confirmation] => :alteration_appt_arranged
      end

      event :delivery_arranged do
        transition delivery_email_sent: :delivery_arranged
      end

      event :alteration_requested do
        transition [:completed, :delivery_arranged, :alteration_appt_arranged] => :alteration_requested
      end

      event :remake_requested do
        transition [:completed, :delivery_arranged, :alteration_appt_arranged] => :remake_requested
      end

      event :sent_to_alterations_tailor do
        transition alteration_requested: :being_altered
      end

      event :back_from_alteration do
        transition being_altered: :partial_at_office, if: :other_items_in_progress?
        transition being_altered: :last_at_office, if: :other_items_at_office?
        transition being_altered: :single_at_office
      end

      event :remade do
        transition remake_requested: :remade
      end

      event :cancel do
        transition any => :cancelled
      end

      event :refund do
        transition any => :refunded
      end

      event :delete_item do
        transition any => :deleted_item
      end

      event :back_to_delivery_email_sent do
        transition delivery_arranged: :delivery_email_sent
      end

      event :shipped_fit_not_confirmed do
        transition delivery_arranged: :shipped_waiting_confirmation
      end

      # GLOBAL STATES

      #triggered_manufacturing global state label
      state :no_measurement_profile, :to_be_checked_profile, :to_be_fixed_profile, :to_be_reviewed_profile, :to_be_submitted_profile, :submitted_profile, :confirmed_profile, :manufacturer_order_created do
        def global_state
          'Manufacturing triggered'
        end
      end

      state :fabric_ordered, :fabric_received, :item_out_of_stock do
        def global_state
          'Manufacturing triggered'
        end
      end

      state :manufacturing do
        def global_state
          'Manufacturing'
        end
      end

      #initial global state
      state :payment_pending do
        def global_state
          'Payment Pending'
        end
      end

      #new global state
      state :new, :new_to_be_measured do
        def global_state
          'New'
        end
      end

      state :fit_confirmed do
        def global_state
          'Fit Confirmed'
        end
      end

      state :waiting_for_confirmation do
        def global_state
          'Waiting for fit confirmation'
        end
      end

      state :inbound_shipping do
        def global_state
          'Inbound shipping'
        end
      end

      state :inbounding do
        def global_state
          'Dispatch to showroom'
        end
      end

      state :partial_at_office, :last_at_office, :single_at_office, :waiting_for_items, :delivery_email_sent, :waiting_for_items_alteration do
        def global_state
          'At office'
        end
      end

      state :delivery_arranged do
        def global_state
          'At office - Delivery arranged'
        end
      end

      state :shipped_unsubmitted do
        def global_state
          'ERROR: Measurement status has been changed to "Saved"'
        end
      end

      state :shipped_waiting_confirmation do
        def global_state
          'Shipped - Waiting for fit confirmation'
        end
      end

      state :shipment_preparation do
        def global_state
          'At office - Shipment preparation'
        end
      end

      state :shipped_confirmed do
        def global_state
          'Shipped - Fit confirmed'
        end
      end

      state :completed do
        def global_state
          'Completed'
        end
      end

      state :alteration_appt_arranged do
        def global_state
          'Alteration appointment arranged'
        end
      end

      state :alteration_requested do
        def global_state
          'Alteration requested'
        end
      end

      state :remake_requested do
        def global_state
          'Remake requested'
        end
      end

      state :being_altered do
        def global_state
          'Being altered'
        end
      end

      state :remade do
        def global_state
          'REMADE'
        end
      end

      state :refunded do
        def global_state
          'REFUNDED'
        end
      end

      state :cancelled do
        def global_state
          'CANCELLED'
        end
      end

      state :deleted_item do
        def global_state
          'DELETED'
        end
      end

      # VALIDATIONS
      state :manufacturer_order_created, :fabric_ordered, :fabric_received do
        validate { |item| item.validate_order_creation }
      end

      state :no_measurement_profile, :to_be_checked_profile, :to_be_fixed_profile, :to_be_reviewed_profile, :to_be_submitted_profile, :submitted_profile, :confirmed_profile do
        validate { |item| item.validate_manufacturer_select unless item.gift_category? }
      end

      state :no_measurement_profile, :to_be_checked_profile, :to_be_fixed_profile, :to_be_reviewed_profile, :to_be_submitted_profile, :submitted_profile, :confirmed_profile do
        validate { |item| item.validate_location }
        validate { |item| item.validate_outfitter }
      end

      state :being_altered do
        validate { |item| item.validate_alteration_tailor }
      end

      state :shipped_unsubmitted, :shipped_waiting_confirmation, :shipped_confirmed do
        validate { |item| item.validate_courier_company }
        validate { |item| item.validate_outbound_number }
      end

      state :delivery_email_sent do
        validate { |item| item.validate_location }
      end

      # AFTER CHANGE TRIGGERS
      after_transition on: :manufacturer_order_created, do: :change_order_status_to_created

      after_transition any => :manufacturing do |item, transition|
        item.submitted!
      end

      after_transition any => :fabric_ordered do |item, transition|
        item.unavailable_ordered_fabric
      end

      after_transition any => :fabric_received do |item, transition|
        item.available_fabric
      end

      after_transition :shipped_waiting_confirmation => :shipped_confirmed do |item, transition|
        item.confirm_profile_category_fit
      end

      after_transition [:partial_at_office, :last_at_office, :single_at_office, :waiting_for_items, :waiting_for_items_alteration] => :delivery_email_sent do |item, transition|
        unless transition.args.last&.dig(:skip_email) || !User.can_send_delivery_emails?(transition.args.last&.dig(:user_id))
          EmailsQueues::CreateDeliveryEmail.(item)
        end
      end

      after_transition shipment_preparation: [:shipped_unsubmitted, :shipped_waiting_confirmation, :shipped_confirmed] do |item, transition|
        unless User.outfitter?(transition.args.last&.dig(:user_id))
          EmailsQueues::CRUD.new(subject: item,
                                 recipient: item.order_customer,
                                 tracking_number: item.outbound_tracking_number,
                                 options: {
                                  link: item.courier_tracking_link,
                                  from: item.sales_location_email_from,
                                  type: :shipping_email,
                                  subject: "#{item&.order_customer&.first_name}, your parcel has been shipped!"
                                 })
                            .create
        end
      end

      after_transition any => [:delivery_email_sent, :shipment_preparation] do |item, transition|
        item.trigger_shipment_preparation_or_delivery_email(transition.event)
      end

      after_transition any => :alteration_requested do |item, transition|
        item.clear_shipment_details
      end

      after_transition :alteration_requested => :being_altered do |item, transition|
        item.update!(sent_to_alteration_date: Time.now)
      end

      after_transition any => :completed do |item, transition|
        item.confirm_profile_category_fit
        item.trigger_waiting_items
        asknicely_response = item.asknicely
        item.logged_events.create(event: 'asknicely_survey_sent',
                                  from: 'not_sent',
                                  to: 'sent',
                                  response: "Sucess: #{asknicely_response['success']}")
      end

      after_transition :delivery_arranged => :delivery_email_sent do |item, transition|
        unless transition.args.last&.dig(:skip_email) || !User.can_send_delivery_emails?(transition.args.last&.dig(:user_id))
          EmailsQueues::CreateDeliveryEmail.(item)
        end
      end

      after_transition being_altered: [:partial_at_office, :last_at_office, :single_at_office] do |item, transition|
        item.update!(back_from_alteration_date: Time.now)
        unless item.current_summary&.items&.any? { |item| item.back_from_alteration_date.nil? }
          item.current_summary&.back_from_alteration!
        end
      end

      after_transition any => :fabric_ordered do |item, transition|
        item.update!(ordered_fabric: true)
      end

      after_transition new_to_be_measured: :new do |item, transition|
        item.update_column(:remind_to_get_measured, nil)
      end
    end
  end
end
