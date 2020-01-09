class TriggerDeliveryArranged
  DELIVERY_EMAIL_STATE = 'delivery_email_sent'.freeze

  def self.call(line_items, day = nil)
    new(line_items, day).trigger
  end

  def initialize(line_items, day)
    @line_items = line_items
    @day = day&.to_date
  end

  def trigger
    filtered_items.each do |item| 
      item.set_appointment_date(day) if item.delivery_arranged && day
    end
  end

  private

  attr_reader :line_items, :day

  def filtered_items
    @filtered_items ||= line_items.select { |item| item.state == DELIVERY_EMAIL_STATE }
  end
end
