ActiveAdmin.register LineItemScope, as: 'Queue' do

  menu parent: "Settings", if: -> { can? :index, LineItemScope }

  before_action :right_sidebar!

  permit_params :label, { states: [], visible_for: [] }, :order, :include_unassigned_items, :show_counter,
                user_sales_location_ids: [], item_sales_location_ids: []

  form do |f|
    f.semantic_errors
    f.inputs do
      input :label
      input :states, as: :select, collection: LineItem::STATE_QUEUES.map { |state, label| [label, state] },
            input_html: { multiple: true, class: 'selectpicker', data: { 'actions-box' => true, 'selected-text-format' => "count > 3" } }
      input :order
      input :show_counter
      input :user_sales_locations, include_blank: true, label: 'Visible for Users with showroom', input_html: { size: 10, style: 'height: 100%;' }
      input :item_sales_locations, include_blank: true, label: 'Visible order items with showroom (select first empty option to nullify assigned showrooms)', input_html: { size: 10, style: 'height: 100%;' }
      input :include_unassigned_items
      input :visible_for, as: :select, collection: User.roles.map { |role, index| [role.humanize, role] },
            input_html: { multiple: true, class: 'selectpicker', data: { 'actions-box' => true, 'selected-text-format' => "count > 3" } }
    end
    f.actions
  end

  show title: 'Queue' do
    attributes_table do
      row :id
      row :label
      row(:states) { |queue| queue.states.map { |state| LineItem::STATE_QUEUES[state.to_sym] }.compact.join(', ') }
      row :order
      row :show_counter
      row(:visible_for) { |queue| queue.visible_for.reject(&:blank?).join(', ') }
      row('Visible for Users with showroom') { |queue| queue.user_sales_locations.pluck(:name).join(', ') }
      row('Visible order items with showroom') { |queue| queue.item_sales_locations.pluck(:name).join(', ') }
      row :include_unassigned_items
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  index download_links: -> { can?(:download_csv, LineItemScope) } do
    id_column
    column :label
    column(:states) { |queue| queue.states.map { |state| LineItem::STATE_QUEUES[state.to_sym] }.compact.join(', ') }
    column :order
    column :show_counter
    column(:visible_for) { |queue| queue.visible_for.reject(&:blank?).join(', ') }
    column('Visible for Users with showroom') { |queue| queue.user_sales_locations.map(&:name).join(', ') }
    column('Visible order items with showroom') { |queue| queue.item_sales_locations.map(&:name).join(', ') }
    column :include_unassigned_items
    column :created_at
    column :updated_at
    actions
  end

  controller do
    def create
      crud = LineItemScopes::CRUD.new(params: params)
      @queue = crud.create
      if crud.success?
        redirect_to queue_path(id: @queue.id)
      else
        render 'new'
      end
    end

    def scoped_collection
      super.includes(:user_sales_locations, :item_sales_locations)
    end
  end
end
