module Customers
  class AcquisitionChannel
    def self.fetch(*attrs)
      new(*attrs).fetch
    end

    def initialize(email)
      @email = email
    end

    def fetch
      BookingTool::AppointmentApi.get_acquisition_channel(
        user_email: User.first.email,
        params: { email: email }
      ).parsed_response
    end

    private

    attr_reader :email
  end
end
