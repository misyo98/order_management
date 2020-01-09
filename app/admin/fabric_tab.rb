ActiveAdmin.register FabricTab do
  menu false
  config.clear_action_items!

  before_filter :right_sidebar!

  permit_params :id, :fabric_category_id, :title, :order

  csv do
    id_column
    column :fabric_category_id
    column :title
    column :order
    column :created_at
    column :updated_at
  end

  index title: 'Customization Tabs', download_links: -> { can?(:download_csv, FabricTab) } do
    selectable_column
    id_column
    column('Category') do |tab|
      span link_to tab.fabric_category.title, fabric_category_path(tab.fabric_category.id) unless tab.fabric_category_id.nil?
    end
    column :title
    column :order
    column :created_at
    column :updated_at
    actions
  end

  show do
    panel 'Customization Tab Details' do
      attributes_table_for fabric_tab do
        row :id
        row('Category') do |tab|
          span link_to tab.fabric_category.title, fabric_category_path(tab.fabric_category.id) unless tab.fabric_category_id.nil?
        end
        row :title
        row :order
        row :created_at
        row :updated_at
      end
    end
  end

  form title: 'Edit Customization Tab' do |f|
    f.inputs do
      f.input :fabric_category
      f.input :title
      f.input :order, input_html: { value: f.object.order || 0 }
    end
    f.actions
  end

  action_item :create, only: :index do
    link_to 'New Customization Tab', new_fabric_tab_path
  end

  action_item :edit, only: :show do
    link_to 'Edit Customization Tab', edit_fabric_tab_path
  end

  action_item :alteration, only: :show do
    link_to 'Delete Customization Tab', fabric_tab_path, method: :delete
  end

  collection_action :reorder, method: :patch

  controller do
    def reorder
      if params[:fabric_tab]
        params[:fabric_tab].each_with_index do |id, index|
          FabricCategory.find(params[:parent_id]).fabric_tabs.where(id: id).update_all(order: index + 1)
        end
      end

      head :ok
    end
  end
end
