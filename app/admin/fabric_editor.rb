ActiveAdmin.register_page 'Fabric Editor', as: 'Customization Editor' do
  menu false

  action_item :fabric_editor, only: :index do
    link_to 'Fabric Editor', fabric_form_path
  end

  controller do
    respond_to :html, :js

    def fabric_category_select
      @page_title = 'Fabric Editor'
      @fabric_categories = FabricCategory.all

      render 'fabric_editor/fabric_category_select'
    end

    def fabric_form
      @fabric_category = FabricCategory.find(params[:category_id])
      @option_dependables = @fabric_category.fabric_options.each_with_object([]) { |option, array| array << option.fabric_option_values }.flatten
        .map { |option_value| [option_value.title, option_value.id] }
    end

    def create_fabric_group
      @fabric_category = FabricCategory.find(params[:id])

      @fabric_category.update(fabric_params)

      @option_dependables = @fabric_category.fabric_options.each_with_object([]) { |option, array| array << option.fabric_option_values }.flatten
        .map { |option_value| [option_value.title, option_value.id] }
    end

    private

    def fabric_params
      params.require(:fabric_category).permit(
        :tuxedo, tuxedo_price: [:SGD, :GBP], fabric_tabs_attributes: [:id, :title, :order, :_destroy,
          fabric_options_attributes: [:id, :tuxedo, :outfitter_selection, :title, :using_dropdown_list, :dropdown_list_id, :max_characters,
            :allowed_characters, :button_type, :placeholder, :order, :premium, :fusible, :manufacturer, :price, :_destroy, depends_on_option_value_ids: [],
            fabric_option_values_attributes: [:id, :title, :order, :tuxedo, :manufacturer, :image_url, :outfitter_selection,
              :premium, :_destroy, price: [ :SGD, :GBP ], depends_on_option_value_ids: []
            ]
          ]
        ]
      )
    end
  end
end
