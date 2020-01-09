ActiveAdmin.register FabricBook do
  decorate_with FabricBookDecorator

  menu false
  config.clear_action_items!
  config.batch_actions = false
  config.paginate = false
  config.sort_order = 'order_asc'

  before_filter :right_sidebar!

  filter :title

  permit_params :id, :title, :order

  csv do
    id_column
    column :title
    column :order
    column :created_at
    column :updated_at
  end

  index download_links: -> { can?(:download_csv, FabricBook) } do
    column do
      span class: 'fas fa-arrows-alt'
    end
    id_column
    column :title
    column :order
    column :created_at
    column :updated_at

    render partial: 'shared/submit_order', locals: { table_name: 'fabric_books' }
  end

  show do
    panel 'Fabric Book Details' do
      attributes_table_for fabric_book do
        row :id
        row :title
        row :order
        row :created_at
        row :updated_at
        row('Archived') { |book| book.archived_field }
      end
    end
  end

  form do |f|
    inputs 'Details' do
      input :title
    end
    actions
  end

  collection_action :archived
  collection_action :reorder, method: :patch

  action_item :archived_books, only: :index do
    link_to 'Archived Books', archived_fabric_books_path
  end

  controller do
    def show
      @fabric_book = FabricBook.with_deleted.find(params[:id]).decorate
      super
    end

    def archived
      @deleted_fabric_books = FabricBook.only_deleted.page(params[:page])
    end

    def reorder
      SetOrder.(items: params[:fabric_book], table_name: :fabric_book) if params[:fabric_book]

      @ordered_books = FabricBook.pluck(:id, :order)
    end
  end
end
