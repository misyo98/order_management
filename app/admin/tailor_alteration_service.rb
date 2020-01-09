ActiveAdmin.register_page 'Services' do
  menu priority: 3, if: -> { current_user.tailor? }

  content do
    alteration_services.each do |category_id, alteration_services|
      h2 "#{categories[category_id]} services"
      table_for(alteration_services, class: 'index_table index alteration-services-table', 'data-url': services_reorder_path) do
        column do
          span class: 'fas fa-arrows-alt'
        end
        column 'Order' do |alteration_service|
          services.find { |tailor_service| tailor_service.alteration_service_id == alteration_service.id }&.order
        end
        column :id
        column :category_id
        column :name
        column current_user.gb_user? ? 'Price (GBP)' : 'Price (SGD)' do |alteration_service|
          assigns[:services].find { |service| service.alteration_service_id == alteration_service.id }&.price
        end
        column :author
      end
    end
  end

  page_action :reorder, method: :patch do
    tailor = current_user.alteration_tailor
    @formatted_order_params =
      params[:alteration_service].each_with_index.each_with_object({}) do |(id, order), formatted_params|
        formatted_params[id] = order
      end

    tailor.alteration_service_tailors.with_deleted.where(alteration_service_id: @formatted_order_params.keys).each do |tailor_service|
      tailor_service.update_attribute(:order, @formatted_order_params[tailor_service.alteration_service_id.to_s])
    end

    render 'admin/services/reorder'
  end

  controller do
    skip_before_action :authorize_access!

    def index
      tailor = current_user.alteration_tailor
      @alteration_services = tailor.alteration_services.non_zero.sort_by(&:category_id).group_by(&:category_id)
      @categories = Category.all.each_with_object({}) { |category, hash| hash[category.id] = category.name }

      @tailors = AlterationTailor.all
      @services = AlterationServiceTailor.with_deleted.where(alteration_tailor_id: current_user.alteration_tailor_id)
      super
    end

    private

    def sorting_order
      return unless params[:order]

      splitted_params = params[:order].split('_')

      sort_order = splitted_params.pop
      sort_column = splitted_params.join('_')

      "#{sort_column} #{sort_order}"
    end

    private

    def reorderable_column(dsl)
      return if params[:q].present? || params[:order] != "order"

      dsl.column(sortable: false) do
        dsl.fa_icon :arrows, class: "js-reorder-handle"
      end
    end

    helper_method :reorderable_column
  end
end
