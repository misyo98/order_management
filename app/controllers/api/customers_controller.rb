class Api::CustomersController < Api::ApplicationController
  skip_before_filter :verify_authenticity_token, only: %i(filter show_by_token trigger_delivery_arranged prepare_shipment_for_courier_delivery
                                                          cancel_delivery category_statuses set_acquisition_channel update_delivery_date)

  before_action :add_origin_header, only: %i(load_customers show_by_token trigger_delivery_arranged prepare_shipment_for_courier_delivery
                                             cancel_delivery category_statuses set_acquisition_channel update_delivery_date)

  before_action :authenticate, only: %i(trigger_delivery_arranged cancel_delivery category_statuses set_acquisition_channel update_delivery_date)

  respond_to :json

  def show_by_token
    @customer = Customer.find_by(token: params[:customer_token])
    respond_with @customer
  end

  #expects params[:options] to contain an array with appointment_day:customer_emails_array hashes
  def filter
    emails = Order.filter_orders(options: params[:options]).pluck('billings.email').uniq
    respond_with emails, location: nil
  end

  def load_customers
    queries = params[:q]&.split(' ')
    @customers = Billing.find_by_query(queries&.dig(0)&.to_s, queries&.dig(0)&.to_s)
      .with_orders_in_date(date: Date.parse(params[:day]))
      .decorate
    respond_with @customers
  end

  def trigger_delivery_arranged
    customer = Customer.find_by(token: params[:customer_token])
    if customer
      line_items = LineItem.for_customer(customer.id)

      TriggerDeliveryArranged.(line_items, params[:day])
    end

    render nothing: true
  end

  def update_delivery_date
    return unless params[:customer_token]
    UpdateDeliveryDate.(Customer.find_by(token: params[:customer_token]), params[:day])
    render nothing: true
  end

  #PATCH /cancel_delivery
  def cancel_delivery
    customer = Customer.find_by(token: params[:customer_token])
    if customer
      line_items = LineItem.for_customer(customer.id).with_state(:delivery_arranged)
      CancelDelivery.(line_items)
    end
    render nothing: true
  end

  #GET /category_statuses
  def category_statuses
    customer = Customer.find_by(id: params[:id])

    @prepared_categories = Customers::CategoryStatusesPreparer.(customer)
  end

  #PATCH /set_acquisition_channel
  def set_acquisition_channel
    customer = Customer.find_by(email: params[:contact_email])
    if customer && customer&.acquisition_channel.nil?
      customer.update!(acquisition_channel: params[:acquisition_channel])
    end
    render nothing: true
  end

  #PATCH /prepare_shipment_for_courier_delivery
  def prepare_shipment_for_courier_delivery
    customer = Customer.find_by(token: params[:customer_token])
    customer_order = customer&.orders&.find_by(id: params[:order_number])

    if customer_order.present?
      customer_order.line_items.each(&:prepare_shipment)
    end

    render nothing: true
  end
end
