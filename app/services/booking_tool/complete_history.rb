module BookingTool
  class CompleteHistory
    HistoryObject = Struct.new(:date, :text)

    def self.generate(*attrs)
      new(*attrs).generate
    end

    def initialize(current_user, customer_email)
      @booking_history = BookingTool::AppointmentApi.booking_history(user_email: current_user.email,
                                                                     params: { email: customer_email })
      @orders = Customer.find_by(email: customer_email)&.orders&.pluck(:id, :created_at)
    end

    def generate
      (form_order_history + form_booking_history).sort_by(&:date)
    end

    private

    attr_reader :booking_history, :orders

    def form_order_history
      return [] unless orders

      orders.each_with_object([]) do |(id, created_at), order_history|
        order_history << HistoryObject.new(created_at, "Placed Order ##{id}")
      end
    end

    def form_booking_history
      booking_history.each_with_object([]) do |history_hash, booking_history|
        booking_history << HistoryObject.new(Time.parse(history_hash['date']), history_hash['text'])
      end
    end
  end
end
