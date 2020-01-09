module BookingTool
  module AppointmentsHelper
    PAGE_LINK_CLASS = 'page-link'.freeze
    PAGE_ITEM_CLASS = 'page-item'.freeze
    ACTIVE_CLASS = 'active'.freeze
    ACTIVE_TAB_CLASSES = [ACTIVE_CLASS, 'in'].freeze
    PAGINATION_CLASS = 'pagination'.freeze
    PREVIOUS = 'Previous'.freeze
    NEXT = 'Next'.freeze
    FIRST_PAGE = 1
    SECOND_PAGE = 2
    THIRD_PAGE = 3
    COUNTRIES_ENUMS = { 'GB' => 0, 'SG' => 1 }.freeze
    BOOKING_TYPES = [["Appointments", 1], ["Deliveries", 0]].freeze
    CITIES = [["Singapore", 1], ["London", 0]].freeze
    DROPPED = 'dropped'.freeze
    OUTFITTERS = 'outfitters'.freeze
    ALL = 'all'.freeze
    CALLBACK = 'callback'.freeze
    BROWSERS_AND_OTHER = 'browsers_and_other'.freeze
    NO_SHOWS_AND_CANCELLED = 'no_shows_and_cancelled'.freeze

    def display_pagination_html(pagination)
      content_tag(:nav) do
        content_tag(:ul, class: PAGINATION_CLASS) do
          [prev_page(pagination.prev_page),
           current_pages(pagination),
           next_page(pagination.next_page)].flatten.inject('') do |links, link_hash|
            links << content_tag(:li, link_hash[:link], class: [PAGE_ITEM_CLASS, link_hash[:active] && ACTIVE_CLASS])
          end.html_safe
        end
      end
    end

    def country_to_enum(user)
      COUNTRIES_ENUMS[user.country]
    end

    def maybe_active_class(scope)
      ACTIVE_CLASS if params[:scope] == scope
    end

    def maybe_active_tab_class(scope)
      ACTIVE_TAB_CLASSES if params[:scope] == scope
    end

    def outfitter_params
      opt = params[:q].clone
      opt[:calendar_country_eq] = country_to_enum(current_user)
      opt.except(:service_service_type_eq)
    end

    def dropped_params
      opt = params[:q].clone
      opt.tap do |params|
        params.delete(:day_gteq)
        params.delete(:day_lteq)
        params.delete(:service_service_type_eq)
        params.delete(:calendar_id_in)
      end
    end

    def all_params
      opt = params[:q].clone
      opt.except(:service_service_type_eq, :calendar_id_in)
    end

    def callback_params
      opt = params[:q].clone
      opt.except(:service_service_type_eq, :calendar_id_in)
    end

    def browsers_and_other_params
      opt = params[:q].clone
      opt.except(:service_service_type_eq, :calendar_id_in)
    end

    def no_shows_and_cancelled_params
      opt = params[:q].clone
      opt.except(:service_service_type_eq, :calendar_id_in)
    end

    def dropped?
      params[:scope] == DROPPED
    end

    def outfitters?
      params[:scope] == OUTFITTERS
    end

    def all?
      params[:scope] == ALL
    end

    def callback?
      params[:scope] == CALLBACK
    end

    def browsers_and_other?
      params[:scope] == BROWSERS_AND_OTHER
    end

    def no_shows_and_cancelled?
      params[:scope] == NO_SHOWS_AND_CANCELLED
    end

    def current_scope_params
      case params[:scope]
      when ALL
        all_params
      when OUTFITTERS
        outfitter_params
      when DROPPED
        dropped_params
      when CALLBACK
        callback_params
      when BROWSERS_AND_OTHER
        browsers_and_other_params
      when NO_SHOWS_AND_CANCELLED
        no_shows_and_cancelled_params
      else
        {}
      end
    end

    def can_see_email?
      current_user.admin? || current_user.ops? || current_user.phone_support?
    end

    private

    def prev_page(page)
      if params[:scope] == DROPPED
        { link: link_to(PREVIOUS, booking_tool_appointments_path(scope: params[:scope], q: current_scope_params, page: page, order: 'created_at desc'), class: PAGE_LINK_CLASS) }
      else
        { link: link_to(PREVIOUS, booking_tool_appointments_path(scope: params[:scope], q: current_scope_params, page: page), class: PAGE_LINK_CLASS) }
      end
    end

    def next_page(page)
      if params[:scope] == DROPPED
        { link: link_to(NEXT, booking_tool_appointments_path(scope: params[:scope], q: current_scope_params, page: page, order: 'created_at desc'), class: PAGE_LINK_CLASS) }
      else
        { link: link_to(NEXT, booking_tool_appointments_path(scope: params[:scope], q: current_scope_params, page: page), class: PAGE_LINK_CLASS) }
      end
    end

    def numbered_page_link(page, active = false)
      if params[:scope] == DROPPED
        { link: link_to("#{page}", booking_tool_appointments_path(scope: params[:scope], q: current_scope_params, page: page, order: 'created_at desc'), class: PAGE_LINK_CLASS), active: active }
      else
        { link: link_to("#{page}", booking_tool_appointments_path(scope: params[:scope], q: current_scope_params, page: page), class: PAGE_LINK_CLASS), active: active }
      end
    end

    def current_pages(pagination)
      if pagination.first_page?
        [numbered_page_link(FIRST_PAGE, true),
         numbered_page_link(SECOND_PAGE),
         numbered_page_link(THIRD_PAGE)]
      else
        [numbered_page_link(pagination.prev_page),
         numbered_page_link(pagination.prev_page + 1, true),
         numbered_page_link(pagination.next_page)]
      end
    end
  end
end
