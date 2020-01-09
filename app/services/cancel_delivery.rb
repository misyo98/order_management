class CancelDelivery
  def self.call(*args)
    new(*args).call
  end

  def initialize(line_items)
    @line_items = line_items
  end

  def call
    line_items.update_all(delivery_appointment_date: nil)
    line_items.each { |item| item.send_delivery_appt_email(skip_email: true) }
  end

  private

  attr_reader :line_items
end
