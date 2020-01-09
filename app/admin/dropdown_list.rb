ActiveAdmin.register DropdownList do
  menu false

  before_filter :right_sidebar!

  filter :title

  permit_params :id, :title

  csv do
    id_column
    column :title
    column :created_at
    column :updated_at
  end

  index download_links: -> { can?(:download_csv, DropdownList) } do
    selectable_column
    id_column
    column :title
    column :created_at
    column :updated_at
    actions
  end

  show do
    panel 'Dropdown List Details' do
      attributes_table_for dropdown_list do
        row :id
        row :title
        row :created_at
        row :updated_at
      end
    end
  end

  form do |f|
    inputs 'Details' do
      input :title
    end
    actions
  end

  controller do
    # def show
    #   super
    # end
  end
end
