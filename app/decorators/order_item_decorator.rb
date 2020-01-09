class OrderItemDecorator < LineItemDecorator
  STATE_NAMES = {
    'payment_pending'               => 'Payment Pending',
    'new'                           => 'Order Received',
    'waiting_for_confirmation'      => 'Waiting for Fit Confirmation',
    'no_measurement_profile'        => 'Processing',
    'to_be_checked_profile'         => 'Processing',
    'to_be_fixed_profile'           => 'Processing',
    'to_be_reviewed_profile'        => 'Processing',
    'to_be_submitted_profile'       => 'Processing',
    'submitted_profile'             => 'Processing',
    'confirmed_profile'             => 'Processing',
    'manufacturer_order_created'    => 'Processing',
    'fabric_ordered'                => 'Processing',
    'fabric_received'               => 'Processing',
    'item_out_of_stock'             => 'Processing',
    'manufacturing'                 => 'Manufacturing',
    'fit_confirmed'                 => 'Fit Confirmed - Processing',
    'inbound_shipping'              => 'Manufacturing',
    'inbounding'                    => 'Dispatch to showroom',
    'partial_at_office'             => 'Dispatch to showroom',
    'last_at_office'                => 'Dispatch to showroom',
    'single_at_office'              => 'Dispatch to showroom',
    'waiting_for_items'             => 'Dispatch to showroom',
    'waiting_for_items_alteration'  => 'At office',
    'delivery_email_sent'           => 'At Office - Please arrange fitting appointment here (with link to booking calendar)',
    'delivery_arranged'             => 'At Office - Fitting appointment arranged',
    'shipped_unsubmitted'           => 'Shipped to Customer',
    'shipped_waiting_confirmation'  => 'Shipped to Customer - Please give us feedback on the fit',
    'shipped_confirmed'             => 'Shipped to Customer',
    'shipment_preparation'          => 'Dispatch to showroom',
    'alteration_appt_arranged'      => 'Alteration appointment arranged',
    'alteration_requested'          => 'Being altered',
    'being_altered'                 => 'Being altered',
    'remake_requested'              => 'Remade',
    'remade'                        => 'Remade',
    'completed'                     => 'Completed',
    'cancelled'                     => 'Cancelled',
    'refunded'                      => 'Refunded',
    'deleted_item'                  => 'Deleted'
  }.freeze

  STATES_FOR_TRACKING_INFO = %w(shipped_unsubmitted shipped_waiting_confirmation shipped_confirmed completed).freeze

  STATE_WITH_LINK = 'delivery_email_sent'.freeze

  def status
    if state == STATE_WITH_LINK
      status_with_link
    else
      STATE_NAMES[state]
    end
  end

  def tracking_link_field
    return unless state.in? STATES_FOR_TRACKING_INFO

    courier_tracking_link
  end

  def tracking_number_field
    return unless state.in? STATES_FOR_TRACKING_INFO

    outbound_tracking_number
  end

  def outbound_tracking_number
    self[:outbound_tracking_number]
  end

  private

  def status_with_link
    link_url = sales_location_delivery_calendar_link
    link = h.link_to "#{link_url}", "#{link_url}?order_token=#{order&.customer.token}"

    "At Office - Please arrange your fitting appointment here #{link}"
  end
end
