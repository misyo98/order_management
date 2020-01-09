ActiveAdmin.register_page 'Call List' do
  menu priority: 5, if: -> { can? :call, Customer }

  content do
    div class: 'sidebar_section panel', id: 'filters_sidebar_section' do
      render "admin/call_list/filters"
    end

    paginated_collection(customers.page(params[:page]).per(40), download_links: false) do
      table_for(collection, sortable: true, class: 'index_table index') do
        column :id
        column :first_name
        column :last_name
        column(:phone) { |customer| customer.billing_phone }
        column :email if current_user.admin?
        # column(:address_1) { |customer| customer.shipping_address_1 }
        # column(:address_2) { |customer| customer.shipping_address_2 }
        column(:postcode) { |customer| customer.shipping_postcode }
        column :orders_count
        column :total_spent
        column(:currency) { |customer| customer.try(:last_order).try(:currency) }
        column(:last_order_date, sortable: 'last_order_created_at') { |customer| l(customer.try(:last_order).try(:created_at), format: :long) }
        column(:status) { |customer| text_field_tag(:status, customer.status, class: 'form-control call-list-status-input', data: { url: customer_path(customer) }) }
        column(:last_contact_date) { |customer| text_field_tag(:last_contact_date, customer.last_contact_date, id: "contact-date-#{customer.id}", class: 'datepicker form-control call-list-last-contact-date', data: { url: customer_path(customer) }) }
      end
    end
  end

  controller do

    def index
      @q = Customer.without_bots.call_list.search(params[:q])
      @q.sorts = sorting_order
      @q2 = @q.result.search(params[:q2]) if params[:q2]
      @customers = @q2.try(:result) || @q.result
      super
    end

    private

    def sorting_order
      return 'created_at desc' unless params[:order]

      splitted_params = params[:order].split('_')

      sort_order = splitted_params.pop
      sort_column = splitted_params.join('_')

      "#{sort_column} #{sort_order}"
    end
  end
end
