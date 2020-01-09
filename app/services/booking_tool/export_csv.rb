module BookingTool
  class ExportCSV
    FIRST_PAGE = 1
    PER_PAGE = 100

    def self.call(*attrs)
      new(*attrs).call
    end

    def initialize(user, params)
      @user = user
      @params = params.merge('per_page' => PER_PAGE)
      @sales_people = ApplicationHelper.sales_persons_collection
      @prepared_data = []
    end

    def call
      add_headers
      collect_data
      generate_csv
    end

    private

    attr_reader :user, :params, :sales_people
    attr_accessor :prepared_data, :raw_appointments, :appointments, :pagination

    def fetch_raw_appointments
      current_page = pagination ? pagination.next_page : FIRST_PAGE
      @raw_appointments = BookingTool::AppointmentApi.index(user_email: user.email, params: params.merge('page' => current_page))
    end

    def form_appointments
      @appointments = raw_appointments.map { |apt_hash| BookingTool::Appointment.new(apt_hash) }
    end

    def form_pagination_info
      @pagination = OpenStruct.new(JSON.parse(raw_appointments.headers['x-pagination']))
    end

    def add_headers
      prepared_data << ['First Name', 'Last Name', 'Email', 'Phone', 'Location', 'Appointment Date', 'Appointment Time', 'Booking Type',
                        'Existing Customer?', 'Last Purchase Date', 'Customer ID', 'Previous Order IDs', 'Previous Outfitter',
                        'Allocated Outfitter', 'Wedding Date', 'Cancelled', 'Purchased', 'Reason for no purchase', 'Comments',
                        'Has active booking?', 'Call count', 'Updated by outfitter', 'Order amount and currency', 'Created At', 'Acquisition Channel']
    end

    def collect_data
      fetch_raw_appointments
      form_appointments
      form_pagination_info
      add_appointments

      return if pagination.last_page?

      collect_data
    end

    def add_appointments
      appointments.each do |appointment|
        appointment = BookingTool::AppointmentCsvDecorator.decorate(appointment, context: { sales_people: sales_people })

        prepared_data << [
          appointment.first_name,
          appointment.last_name,
          appointment.email,
          appointment.phone,
          appointment.city,
          appointment.day,
          appointment.time,
          appointment.booking_type,
          appointment.existing_customer_with_several_orders,
          appointment.maybe_last_purchase_date,
          appointment.maybe_customer_id,
          appointment.previous_order_numbers,
          appointment.previous_outfitter,
          appointment.allocated_outfitter,
          appointment.wedding_date,
          appointment.formatted_cancelled,
          appointment.formatted_purchased,
          appointment.no_purchase_reason_field,
          appointment.comment,
          appointment.formatted_active_booking,
          appointment.formatted_call_count,
          appointment.outfitter_that_updated,
          appointment.recent_order,
          appointment.submitted,
          appointment.maybe_acquisition_channel
        ]
      end
    end

    def generate_csv
      CSV.generate(headers: true) do |csv|
        prepared_data.each do |row|
          csv << row
        end
      end
    end
  end
end
