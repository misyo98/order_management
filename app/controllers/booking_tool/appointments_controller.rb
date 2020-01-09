module BookingTool
  class AppointmentsController < ApplicationController
    include BookingTool::AppointmentsHelper

    before_action :resolve_default_filters, only: :index, if: proc { no_scope_given? }

    respond_to :html, :json, :js

    def index
      @calendars = BookingTool::AppointmentApi.calendars(params: { country: current_user.country.parameterize },
                                                         user_email: current_user.email)
      appointments = BookingTool::AppointmentApi.index(user_email: current_user.email, params: params)
      @sales_people = ApplicationHelper.sales_persons_collection.insert(0, [nil, ''])
      @appointments = appointments.map { |apt_hash| BookingTool::Appointment.new(apt_hash) }
      @pagination_scope = OpenStruct.new(JSON.parse(appointments.headers['x-pagination'])) if appointments.headers['x-pagination']
    end

    def update
      @appointment = BookingTool::CRUD::Update.(current_user, bip_appointment_params, extra_update_params)

      respond_with @appointment
    end

    def called
      @appointment = BookingTool::CRUD::Called.(current_user, params[:id])

      respond_with @appointment
    end

    def call_later
      @appointment_id = params[:id]
    end

    def update_callback_date
      @appointment = BookingTool::CRUD::UpdateCallbackDate.(current_user, appointment_params)
      @date = appointment_params[:callback_date]

      respond_with @appointment, @date
    end

    def call_history
      @calls = BookingTool::AppointmentApi.call_history(user_email: current_user.email, params: params)

      respond_with @calls
    end

    def removed_by_ops
      @appointment = BookingTool::CRUD::Update.(current_user, bip_appointment_params)

      respond_with @appointment
    end

    def no_show
      @appointment = BookingTool::CRUD::Update.(current_user, bip_appointment_params)

      Customer.find(params[:customer_id]).line_items.with_state('delivery_arranged').update_all(state: :delivery_email_sent)
    end

    def set_default_calendars
      cookies['default-calendars-filter'] = JSON.generate(params[:filter])
    end

    def booking_history
      complete_history = BookingTool::CompleteHistory.generate(current_user, params[:email]) if params[:email]
      @booking_history = complete_history || []
    end

    def generate_csv
      ExportAppointmentsCsv.perform_async(current_user.id, params)
      head :ok
    end

    def export_csv
      url = "public/#{TempFile.find_by(id: params[:file_id]).attachment_url}"

      send_file(
        url,
        filename: "appointment_list_#{DateTime.now.strftime('%F')}.csv",
        type: "application/csv"
      )
    end

    def dropped_events
      @droped_dates = params[:dropped_dates]
    end

    private

    def bip_appointment_params
      params.require('object Object').permit(:allocated_outfitter_id, :no_purchase_reason, :customer_email,
                                             :follow_up_status, :updated_by_outfitter, :removed_by_ops, :removed_from_dropped,
                                             :order_tool_outfitter_id, :wedding_date, :callback_date)
                                     .merge!(id: params[:id])
    end

    def appointment_params
      params.permit(:callback_date).merge!(id: params[:id])
    end

    def extra_update_params
      params.permit(:removing, :customer_id, :force_update)
    end

    def resolve_default_filters
      params.reverse_merge!(scope: 'outfitters', q: { calendar_id_in: default_calendars_filter['calendar_ids'],
                                                      calendar_country_eq: country_to_enum(current_user),
                                                      day_lteq: Date.today })
    end

    def default_calendars_filter
      return {} if cookies['default-calendars-filter'].blank?

      JSON.parse(cookies['default-calendars-filter'])
    end

    def no_scope_given?
      params[:scope].blank?
    end
  end
end
