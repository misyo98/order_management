module BookingTool
  class AppointmentApi < BookingTool::API
    def self.index(*args)
      new(*args).index
    end

    def self.update(*args)
      new(*args).update(args.first.fetch(:params))
    end

    def self.calendars(*args)
      new(*args).calendars
    end

    def self.called(*args)
      new(*args).called(args.first.fetch(:params))
    end

    def self.call_later(*args)
      new(*args).call_later(args.first.fetch(:params))
    end

    def self.update_callback_date(*args)
      new(*args).update_callback_date(args.first.fetch(:params))
    end

    def self.call_history(*args)
      new(*args).call_history(args.first.fetch(:params))
    end

    def self.booking_history(*args)
      new(*args).booking_history(args.first.fetch(:params))
    end

    def self.get_acquisition_channel(*args)
      new(*args).get_acquisition_channel
    end

    def index
      self.class.get('/appointments', options)
    end

    def update(params)
      self.class.patch("/appointments/#{params[:id]}", options)
    end

    def called(params)
      self.class.patch("/appointments/#{params[:id]}/called", options)
    end

    def update_callback_date(params)
      self.class.patch("/appointments/#{params[:id]}/update_callback_date", options)
    end

    def calendars
      self.class.get('/appointments/calendars', options)
    end

    def call_history(params)
      self.class.get("/appointments/#{params[:id]}/calls", options)
    end

    def booking_history(params)
      self.class.get('/appointments/customer_booking_history', options)
    end

    def get_acquisition_channel
      self.class.get('/appointments/get_acquisition_channel', options)
    end
  end
end
