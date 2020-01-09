module Asknicely
  class API
    include HTTParty

    base_uri ENV['asknicely_url']

    attr_reader :email, :first_name, :last_name, :segment

    def initialize(params)
      @email        = params.fetch(:email, '')
      @first_name   = params.fetch(:first_name, '')
      @last_name    = params.fetch(:last_name, '')
      @segment      = params.fetch(:segment, '')
    end

    def send_survey
      self.class.post('/person/trigger', 
                        body: { email: email, 
                                first_name: first_name, 
                                last_name: last_name, 
                                segment: segment,
                                addperson: true
                              },
                        headers: { 'X-apikey' => "#{ENV['asknicely_token']}" }
                      )
    end

  end
end
