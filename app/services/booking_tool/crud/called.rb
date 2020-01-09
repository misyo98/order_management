module BookingTool
  module CRUD
    class Called
      def self.call(*args)
        new(*args).call
      end

      def initialize(user, id)
        @user = user
        @appointment = BookingTool::Appointment.new(id: id)
      end

      def call
        response = BookingTool::AppointmentApi.called(user_email: user.email,
                                                      params: { id: appointment.id })
        if response.success?
          appointment.assign_attributes(response['appointment'])
        else
          appointment.errors.add(:base, message: 'BookingTool: Error')
        end

        appointment
      end

      private

      attr_reader :user, :appointment
    end
  end
end
