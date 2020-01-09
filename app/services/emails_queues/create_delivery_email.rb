module EmailsQueues
  class CreateDeliveryEmail
    STATES_FOR_DELIVERY = [
      'partial_at_office', 'last_at_office', 'single_at_office', 'waiting_for_items',
      'inbounding', 'waiting_for_items_alteration', 'delivery_email_sent'
    ].freeze

    def self.call(args)
      new(args).create
    end

    def initialize(item)
      @item = item
      @order = item.order
      @profile = item.order_customer.profile
      @confirmed_categories = order.customer&.profile&.categories&.where(status: ProfileCategory.statuses[:confirmed])&.includes(:category)&.pluck('categories.name') || []
      @submitted_categories = order.customer&.profile&.categories&.where(status: ProfileCategory.statuses[:submitted])&.includes(:category)&.pluck('categories.name') || []
    end

    def create
      EmailsQueues::CRUD.new(subject: item,
                             recipient: item.order_customer,
                             delivery_email_layout: resolve_delivery_email_layout,
                             options: {
                               link: item.sales_location_delivery_calendar_link,
                               from: item.sales_location_email_from,
                               type: :delivery_email,
                               subject: "#{item&.order_customer&.first_name}, please book your fitting appointment!"
                             })
                        .create
    end

    private

    attr_reader :item, :order, :profile, :confirmed_categories, :submitted_categories

    def resolve_delivery_email_layout
      if items_confirmed_condition || items_confirmed_and_submitted_condition
        :with_courier_button
      else
        :regular
      end
    end

    def items_confirmed_condition
      fitting_items = order.line_items.where(state: STATES_FOR_DELIVERY)

      return false if fitting_items.empty?

      fitting_items.all? { |item| item.local_category.all? { |category| category.in?(confirmed_categories) } }
    end

    def items_confirmed_and_submitted_condition
      fitting_items = order.line_items.where(state: STATES_FOR_DELIVERY - ['inbounding'])

      return false if fitting_items.empty?

      fitting_items.all? do |item|
        item.local_category.all? { |category| category.in?(confirmed_categories) || (category.in?(submitted_categories) && after_alteration?(item)) }
      end
    end

    def after_alteration?(item)
      item.logged_events.order(created_at: :desc).take(5).any? { |event| event.from == 'being_altered' }
    end
  end
end
