# frozen_string_literal: true

ActiveAdmin.register AlterationService do
  menu parent: "Settings", if: -> { can? :index, AlterationService }
  permit_params :name, :category_id, :order, :author_id, alteration_service_tailors_attributes: [:id, :alteration_tailor_id, :price]
  config.sort_order = 'order_asc'
  config.paginate = false

  collection_action :deleted, method: :get
  collection_action :fetch_services, method: :get
  collection_action :create, method: :post
  collection_action :find_service_tailor, method: :get

  index title: 'Alteration Services', download_links: -> { can?(:download_csv, AlterationService) } do
    grouped_services.each do |category_id, alteration_services|
      h2 "#{categories[category_id]} services"
      table_for(alteration_services, sortable: false, class: 'index_table index alteration-servicess-table') do
        column :id
        column :category_id
        column :name
        column :order
        assigns[:tailors].each do |tailor|
          column "#{tailor.name} (#{tailor.decorate&.formatted_currency})" do |alteration_service|
            service_with_price = assigns[:services][alteration_service.id]&.find { |service| service.alteration_tailor_id == tailor.id }&.price
            service_with_price.nil? ? 'n/a' : service_with_price
          end
        end
        column :author
        actions
      end
    end
  end

  show do
    attributes_table do
      row :id
      row :category
      row :name
      row :order
      assigns[:services].each do |service|
        row "#{service.alteration_tailor_name} (#{service.alteration_tailor&.decorate&.formatted_currency})" do |alteration_service|
          service.price
        end
      end
      row :author
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :category
      f.input :name
      f.input :order, input_html: { value: f.object.order || 0 }
    end
    f.inputs "Alteration tailors price", class: 'alteration-tailors' do
      AlterationTailor.all.decorate.each do |tailor|
        f.inputs "#{tailor.name} (#{tailor.formatted_currency})" do
          tailor_price = f.object.alteration_service_tailors.where(alteration_tailor_id: tailor.id)
          if tailor_price.blank?
            tailor_price = f.object.alteration_service_tailors.build(alteration_tailor_id: tailor.id)
          end
          f.inputs for: [:alteration_service_tailors, tailor_price] do |n|
            n.input :alteration_tailor_id, as: :hidden, input_html: { value: tailor.id }
            n.input :price, input_html: { value: n.object.price }, label: false
          end
        end
      end
      f.input :author_id, as: :hidden, input_html: { value: current_user.id }
    end
    f.actions
  end

  # ACTION ITEMS IS A BUTTON UP ABOVE IN THE RIGHT CORNER
  action_item :deleted_services, only: :index do
    link_to 'Deleted services', deleted_alteration_services_path
  end

  controller do
    before_action :set_categories, only: [:index, :deleted]

    def create
      @service = AlterationService.find_or_initialize_by(name: params[:alteration_service][:name])
      @service.assign_attributes(service_params)
      @service.save
      @service_tailor = @service.alteration_service_tailors.find_by(alteration_tailor_id: @service.author.alteration_tailor_id)

      respond_to do |format|
        format.html { redirect_to @service, notice: 'Alteration Service created!' }
        format.js { render 'alteration_services/create' }
      end
    end

    def index
      @grouped_services = AlterationService.ransack(params[:q]).result.order(category_id: :asc).group_by(&:category_id)
      @tailors = AlterationTailor.all
      @services = AlterationServiceTailor.all.group_by(&:alteration_service_id)
      super
    end

    def show
      @alteration_service = AlterationService.find(params[:id])
      @services = @alteration_service.alteration_service_tailors.includes(:alteration_tailor)
    end

    def fetch_services
      @alteration_services = AlterationService.ransack(params[:q]).result

      respond_with @alteration_services
    end

    def deleted
      @deleted_services = AlterationService.only_deleted.group_by(&:category_id)
      @services = AlterationServiceTailor.only_deleted
    end

    def set_categories
      @categories = Category.all.each_with_object({}) { |category, hash| hash[category.id] = category.name }
    end

    def find_service_tailor
      @alteration_service_tailor = AlterationServiceTailor.ransack(params[:q]).result.first
    end

    private

    def service_params
      params.require(:alteration_service).permit(
        :category_id, :name, :order, :custom, :author_id,
        alteration_service_tailors_attributes: [:id, :alteration_tailor_id, :price]
      )
    end
  end
end
