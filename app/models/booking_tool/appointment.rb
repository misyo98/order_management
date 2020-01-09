module BookingTool
  class Appointment
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    attr_accessor :id, :day, :start, :end, :calendar, :location, :full_name, :first_name, :last_name, :email, :dropped_events,
                  :phone, :address, :deleted_at, :ip, :url, :referer, :submitted, :booking_type, :cancelled, :purchased, :no_purchase_reason,
                  :customer_email, :allocated_outfitter_id, :needs_follow_up, :follow_up_status, :updated_by_outfitter,
                  :call_count, :last_call_date, :removed_by_ops, :reschedule_link, :order_number, :country, :removed_from_dropped,
                  :order_tool_outfitter_id, :active_booking, :wedding_date, :acquisition_channel, :callback_date

    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end

    def persisted?
      false
    end

    def to_model
      self
    end

    def assign_attributes(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end
  end
end
