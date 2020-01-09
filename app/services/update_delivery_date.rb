class UpdateDeliveryDate
  def self.call(customer, day = nil)
    new(customer, day).call
  end

  def initialize(customer, day)
    @customer = customer
    @day = day&.to_date
  end

  def call
    LineItem.for_customer(customer.id).with_state(:delivery_arranged).each do |item| 
      item.set_appointment_date(day) if day.present?
    end
  end

  private

  attr_reader :customer, :day
end
