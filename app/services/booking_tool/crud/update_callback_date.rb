module BookingTool
  module CRUD
    class UpdateCallbackDate
      def self.call(*args)
        new(*args).call
      end

      def initialize(user, params)
        @user = user
        @params = params
        @appointment = BookingTool::Appointment.new(params)
      end

      def call
        return appointment if appointment.errors.any?

        response = BookingTool::AppointmentApi.update_callback_date(user_email: user.email, params: params)
        unless response.success?
          appointment.errors.add(:base, message: 'BookingTool: Error')
        end

        appointment
      end

      private

      attr_reader :user, :params, :appointment
    end
  end
end
