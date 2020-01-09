module BookingTool
  class API
    URI = ENV['booking_tool_url'].freeze
    AUTH_TOKEN = ENV['booking_tool_api_key'].freeze

    include HTTParty

    base_uri URI

    def initialize(user_email:, params: {})
      @options = { body: params.merge!(user_email: user_email).to_json,
                   headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json',
                              'Authorization' => "Token token=#{AUTH_TOKEN}" } }
    end

    private

    attr_reader :options
  end
end
