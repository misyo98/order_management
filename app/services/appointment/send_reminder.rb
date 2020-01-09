module Appointment
  class SendReminder
    SCOPE = 'outfitters'.freeze
    COUNTRIES = %w(GB SG).freeze
    ERROR_MESSAGE = 'Unavailble country'.freeze
    GB = 'GB'.freeze
    USER_EMAIL = 'orders@editsuits.com'.freeze
    DATE_FORMAT = '%Y-%m-%d'.freeze
    REGEXP_PATTERN = /\/api.*/.freeze
    REGEXP_REPLACEMENT = '/appointments/'.freeze

    def initialize(country:)
      @country = country.upcase

      after_initialize
    end

    def self.call(*args)
      new(*args).call
    end

    def call
      response = BookingTool::AppointmentApi.index(user_email: USER_EMAIL, params: booking_params)
      return if response.parsed_response.blank?

      appointments = response.map { |apt_hash| BookingTool::Appointment.new(apt_hash) }

      AppointmentMailer.send_booking_reminder(receivers: receivers, appointments: appointments, url: url).deliver_now
    end

    private
    attr_reader :country

    def after_initialize
      raise ERROR_MESSAGE unless @country.in? COUNTRIES
    end

    def booking_params
      {
        scope: SCOPE,
        q: {
          day_lteq: Date.today.strftime(DATE_FORMAT),
          calendar_country_eq: country_id
        }
      }
    end

    def country_id
      country == GB ? 0 : 1
    end

    def receivers
      User.appointments_people(country).pluck(:email)
    end

    def url
      ENV['booking_tool_url'].gsub(REGEXP_PATTERN, REGEXP_REPLACEMENT)
    end
  end
end
