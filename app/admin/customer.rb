ActiveAdmin.register Customer do
  decorate_with CustomerDecorator

  actions :all, except: [:destroy, :edit]
  before_action :right_sidebar!
  menu priority: 12, if: -> { can? :read, Customer }

  permit_params :first_name, :last_name, :email, :status, :last_contact_date

  filter :first_name
  filter :last_name
  filter :email
  filter :categories_in, as: :select, label: 'Category', collection: -> { Category.visible.pluck(:name, :id) }
  filter :profile_categories_status_eq, as: :select, label: 'Status', collection: ProfileCategory.statuses
  filter :with_order, as: :string

  show title: :first_name, decorate: true do
    panel "Customer Details" do
      attributes_table_for customer do
        row :first_name
        row :last_name
        row :email
        row :age
        row :weight
        row :weight_unit
        row :created_at
        row :acquisition_channel
      end
    end

    render 'admin/customer/checkboxes', checked: true, categories: Category.all.pluck(:name, :id), custom_class: 'profile-categories'

    render 'admin/customer/copy_button'

    render 'admin/customer/measurements_table', context: self, profile: customer.profile, category_params: category_params, comments: comments, infos: infos if customer.profile

    render 'admin/customer/copy_table/table', context: self, profile: customer.profile, category_params: category_params, infos: infos if customer.profile

    panel 'Images' do
      if customer.profile
        customer.profile.images.each do |image|
          span class: 'inline-block', id: "profile-image-#{image.id}" do
            (link_to image_tag(image.image_url, height: '120'), image.image_url, class: :fancybox, rel: :group) +
            (link_to 'Delete image', profile_image_path(image.id), class: 'delete-image', remote: true, method: :delete, data: { confirm: 'Are you sure?' })
          end
        end
      end
    end

    panel 'Alteration Overview' do
      if can? :read, AlterationSummary
        table_for summaries, class: "table" do
          column(:altered_categories) { |summary| summary.altered_categories.join(', ') }
          column(:type) { |summary| summary.request_type_field }
          column :created_at
          column(:manufacturer_number) { |summary| summary.alteration_infos.first.manufacturer_code }
          column '' do |summary|
            span link_to 'Print', alteration_summary_path(id: summary.id, format: :pdf), class: 'btn btn-info'
            span link_to 'Edit', edit_alteration_summary_path(id: summary.id), class: 'btn btn-warning'
            span link_to 'Images', alteration_summary_alteration_images_path(summary.id), class: 'btn btn-success', remote: true if summary.images.any?
            span link_to 'Delete', alteration_summary_path(id: summary.id), class: 'btn btn-danger delete-alteration-button',
              data: { 'customer-id': summary.profile.customer_id, 'latest-category-alteration': summary.latest_category_alteration? } if current_user.admin?
          end
        end
      end
    end

    panel 'Measurement Category status' do
      if customer.profile
        attributes_table_for customer.profile.categories do
          row :category_name
          row(:status) do |profile_category|
            span class: 'far fa-edit', 'aria-hidden': true, id: "#{profile_category.id}-status" do
              best_in_place_if can?(:edit, ProfileCategory), profile_category, :status,
                as: :select, collection: ProfileCategory.statuses.keys.map { |s| [s, s.humanize] },
                activator: "##{profile_category.id}-status"
            end
          end
          row(:manufacturer) do |profile_category|
            item = customer_items.order(created_at: :desc).find { |item| categories[profile_category.category_id].in? LineItem::CATEGORY_KEYS[item.product_category] }
            LineItem::MANUFACTURERS[item.manufacturer.to_sym] if item
          end
          row(:history) do |profile_category|
            link_to 'Show', history_profile_category_path(profile_category), remote: true
          end
        end
      end
    end

    panel "Measurement profile details", only: :show do
      if customer.profile

        attributes_table_for customer.profile do
          row :author_name
          row :created_at
        end
      end
    end

    panel 'Detached profiles' do
      if customer.profile
        span link_to 'Detach profile',  customer_profile_path(customer_id: customer.id, id: customer.profile.id), method: :delete,
          data: { confirm: "You sure you want to delete this profile?" }, class: 'btn btn-danger'
      end
      ul
        Profile.only_deleted.where(customer_id: customer.id).each do |profile|
          li link_to "Detached on #{ profile.deleted_at.strftime('%B %d, %Y %H:%M') }", detached_profile_path(profile_id: profile.id)
        end
    end
  end

  action_item :new_measurement, only: :show do
    if can?(:edit, Customer) || can?(:add_new_measurement, Customer)
      link_to 'Save or fix measurements', new_measurement_path(customer_id: customer.id, review: false)
    end
  end

  action_item :alteration, only: :show do
    if (can?(:edit, Customer) || can?(:save_adjustments, Customer)) && customer.profile
      link_to 'Adjust confirmed measurements', edit_customer_profile_path(customer, customer.profile, without_extra_fields: true)
    end
  end

  action_item :review, only: :show do
    if customer.can_be_reviewed_by?(current_user)
      link_to 'Review and submit measurements', new_measurement_path(customer_id: customer.id, review: true)
    end
  end

  action_item :check, only: :show do
    if customer.can_be_checked_by?(current_user)
      link_to 'Check measurements', new_measurement_path(customer_id: customer.id, review: true)
    end
  end

  action_item :see_submission, only: :show do
    if customer.profile&.categories&.map(&:unsubmitted_status?)&.exclude?(true)
      link_to 'See Submission', see_submission_customer_path(id: customer.id)
    end
  end

  action_item :view_orders, only: :show do
    link_to 'View orders', line_items_path(q: { order_customer_id_eq: customer.id })
  end

  action_item :measurements_csv_filters, only: :index do
    if can?(:measurements_csv_filters, Customer)
      link_to 'Measurements CSV Filters', measurements_csv_filters_customers_path
    end
  end

  # action_item :waistcoats_csv, only: :index do
  #   link_to 'Download Waistcoat measurements', waistcoats_measurements_customers_path({ format: :csv }.deep_merge!(params))
  # end

  index(download_links: -> { can?(:download_csv, Customer) }) do
    render 'admin/customer/index', context: self
  end

  collection_action :load_customers,            method: :get
  collection_action :info,                      method: :get
  collection_action :waistcoats_measurements,   method: :get
  collection_action :measurements_csv_filters,  method: :get
  collection_action :generate_measurements_csv, method: :get
  collection_action :download_measurements_csv, method: :get

  member_action :active_items,   method: :get
  member_action :all_items,      method: :get
  member_action :see_submission, method: :get

  controller do
    respond_to :html, :json, :js
    rescue_from ActiveRecord::RecordNotFound, with: :customer_not_found

    def scoped_collection
      super.with_includes.without_bots
    end

    def show
      @category_params    = CategoryParam.all.includes(:category, :param).order(:order).group_by(&:category_id)
      @infos              = AlterationInfo.includes(:author).for_customer(customer_id: params[:id]).group_by(&:category_id)
      @comments           = ActiveAdmin::Comment.where(resource_type: 'Customer', resource_id: params[:id])
      @decorated_comments = CommentsDecorator.decorate(@comments)
      @comments           = @comments.group_by(&:category_id)
      profile             = Profile.find_by(customer_id: params[:id])
      summaries           = AlterationSummary.where(profile_id: profile&.id).includes(:alteration_infos).order(created_at: :desc)
      @summaries          = summaries.map { |summary| summary.decorate if summary.alteration_infos.any? }.compact
      @customer_items     = Customer.find(params[:id]).line_items.select(:manufacturer, :product_id).includes(:product)
      @categories         = Category.all.each_with_object({}) { |category, hash| hash[category.id] = category.name }
      super
    end

    def info
      @customer        = Customer.includes(:orders, profile: :fits)
                            .select(:id, :first_name, :last_name, :email)
                            .find_by(id: params[:id])
      @categories      = Category.all.select(:id, :visible, :name)
      @review          = ActiveRecord::Type::Boolean.new.type_cast_from_user(params[:review])
      @profile         = @customer.profile || @customer.build_profile
      @country         = @customer.orders.last&.billing&.country

      Customers::Builder.build_fits(object: @profile)

      respond_with @customer
    end

    def see_submission
      @customer           = Customer.with_includes.find_by(id: params[:id])
      @profile            = @customer.profile.decorate
      @categories         = Category.where(id: @profile.categories.map(&:category_id)).select(:id, :visible, :name, :order).order(:order)
      @body_category      = Category.find_by(name: 'Body shape & postures')
      @height_category    = Category.find_by(name: 'Height')
      @fits               = @profile.fits.where.not(category_id: [@body_category.id, @height_category.id])
      @measurement_params = @profile.measurements.map(&:category_param)
      @profile_categories = @profile.categories.each_with_object({}) { |p_c, response| response[p_c.category_id] = p_c  }
      @outfitter          = current_user.decorate
      @category_params    = CategoryParam.all.includes(:category, :param).order(:order).group_by(&:category_id)
      @comments           = @customer.comments.order(submission: :desc)
      @checks             = MeasurementCheck.all.select(:id, :category_param_id, :min, :max,
                                                  :percentile_of, :calculations_type)
                                                  .group_by(&:category_param_id)

      render 'customers/see_submission'
    end

    def load_customers
      queries = params[:q]&.split(' ')
      @customers = Customer.find_by_query(queries.dig(0).to_s, queries.dig(0).to_s).without_bots.decorate

      respond_with @customers
    end

    def waistcoats_measurements
      customers = Customer.search(params[:q]).result
      respond_to do |format|
        format.csv do
          file = Exporters::Objects::CustomersWaistcoats.new(records: customers).call
          send_data file, filename: "customers-waistcoats-#{Date.today}.csv"
        end
      end
    end

    def active_items
      @customer = Customer.find(params[:id])
      @line_items = @customer.line_items.active_state.order(id: :desc)
    end

    def all_items
      @customer = Customer.find(params[:id])
      @line_items = @customer.line_items.order(id: :desc)

      render 'active_items'
    end

    def measurements_csv_filters
      authorize! :measurements_csv_filters, Customer

      @q = Profile.ransack(params[:q])
    end

    def generate_measurements_csv
      MeasurementsGenerateCsv.perform_async(params[:q])

      head :ok
    end

    def download_measurements_csv
      send_file(
        "public/#{TempFile.find_by(id: params[:data_id]).attachment_url}",
        filename: "measurements-#{Date.current}.csv",
        type: "application/csv"
      )
    end

    private

    def customer_not_found
      flash[:alert] = "Customer does not exists or is a bot"
      redirect_to :back
    end
  end
end
