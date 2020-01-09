class LineItemStateTransitionDecorator < Draper::Decorator
  delegate_all

  STATES_FOR_DISPLAY = {
    new:                          'New',
    new_to_be_measured:           'New - To be measured',
    no_measurement_profile:       'Manufacturing triggered',
    to_be_checked_profile:        'Manufacturing triggered - Measurement profile needs to be checked',
    to_be_fixed_profile:          'Manufacturing triggered - Measurement profile needs to be fixed',
    to_be_reviewed_profile:       'Manufacturing triggered - Measurement profile needs to be reviewed',
    to_be_submitted_profile:      'Manufacturing triggered - Measurement profile needs to be submitted',
    submitted_profile:            'Manufacturing triggered - Measurement profile submitted',
    manufacturer_order_created:   'Manufacturer order created - Fabric: Cut length',
    fabric_ordered:               'Cut length fabric ordered',
    fabric_received:              'Manufacturer order created - Fabric available',
    item_out_of_stock:            'Manufacturer order created - Out of stock',
    waiting_for_confirmation:     'Waiting for fit confirmation',
    fit_confirmed:                'Fit confimed',
    manufacturing:                'Item submitted',
    inbound_shipping:             'Inbound shipping',
    inbounding:                   'Dispatch to showroom',
    single_at_office:             'At office',
    last_at_office:               'At office',
    partial_at_office:            'At office',
    waiting_for_items:            'At office - Waiting for other items',
    waiting_for_items_alteration: 'At office - Waiting for other items (Alteration / Remake)',
    delivery_email_sent:          'Delivery email sent',
    delivery_arranged:            'Delivery arranged',
    shipped_unsubmitted:          'ERROR - Measurements changed to "Saved"',
    shipped_waiting_confirmation: 'Shipped, fit not confirmed',
    shipped_confirmed:            'Shipped, fit confirmed',
    alteration_appt_arranged:     'Alteration appointment arranged',
    alteration_requested:         'Alteration requested',
    remake_requested:             'Remake requested',
    being_altered:                'Being altered',
    completed:                    'Completed',
    cancelled:                    'Cancelled',
    refunded:                     'Fully refunded',
    shipment_preparation:         'Shipment preparation',
    remade:                       'Remade',
    deleted_item:                 'Deleted',
    delivery_email_resent:        'Delivery email resent'
  }.with_indifferent_access.freeze

  def tailor_step
    "Alteration tailor: #{tailor_name}"
  end

  def username
    "#{user_first_name} #{user_last_name}"
  end

  def date
    created_at.strftime('%m/%d/%Y')
  end

  def comment_step
    "Comment: #{comment_body}"
  end

  def courier_step
    "Courier company: #{courier_name}"
  end

  def event_step
    STATES_FOR_DISPLAY[to]
  end

  def asknicely_step
    "Asknicely survey sent. Response from API: #{response}"
  end

  def resolve_step
    case
    when comment_event?
      comment_body
    when asknicely_event?
      asknicely_step
    when ordered_fabric_event?
      ordered_fabric_step
    else
      event_step
    end
  end

  def default_event_step?
    !comment_event? && !asknicely_event?
  end

  def display_tailor?
    default_event_step? && tailor
  end

  def display_courier?
    default_event_step? && courier
  end

  def ordered_fabric_step
    "Ordered fabric was changed from #{from} to #{to}"
  end

  private

  def comment_event?
    comment_body.present?
  end

  def asknicely_event?
    event == 'asknicely_survey_sent'
  end

  def ordered_fabric_event?
    event == 'ordered_fabric_updated'
  end
end
