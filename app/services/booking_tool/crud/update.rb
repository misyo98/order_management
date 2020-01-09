module BookingTool
  module CRUD
    class Update
      DELIVERY_STATES = ['delivery_email_sent', 'delivery_arranged'].freeze
      TRUE = 'true'

      def self.call(*args)
        new(*args).call
      end

      def initialize(user, params, extra_params = {})
        @user = user
        @params = params
        @extra_params = extra_params
        @appointment = BookingTool::Appointment.new(params)
      end

      def call
        maybe_validate_items_state
        return appointment if appointment.errors.any?

        response = BookingTool::AppointmentApi.update(user_email: user.email, params: params)
        if response.success?
          appointment.assign_attributes(response['appointment'])
        else
          appointment.errors.add(:base, message: 'BookingTool: Error')
        end

        appointment
      end

      private

      attr_reader :user, :params, :appointment, :extra_params

      def maybe_validate_items_state
        if extra_params[:removing] && !force_update? && customer_has_items_in_delivery?
          appointment.errors.add(:base, message: 'This item can’t be removed, please change the item states')
        end
      end

      def customer_has_items_in_delivery?
        Customer.find_by(id: extra_params[:customer_id])&.line_items&.with_states(DELIVERY_STATES)&.any?
      end

      def force_update?
        extra_params[:force_update] == TRUE
      end
    end
  end
end
