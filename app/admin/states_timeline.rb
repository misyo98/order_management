ActiveAdmin.register StatesTimeline do
  decorate_with StatesTimelineDecorator

  menu parent: 'Settings', if: -> { can? :index, StatesTimeline }

  config.sort_order = 'id_asc'
  config.per_page = 40

  permit_params [:state, :from_event, :allowed_time_uk, :allowed_time_sg, :time_unit,
                  :expected_delivery_time_uk, :expected_delivery_time_sg,
                  sales_location_timelines_attributes: [:id, :_destroy, :allowed_time, :expected_delivery_time, :sales_location_id,
                                                        :states_timeline_id]]

  filter :state
  filter :from_event
  filter :allowed_time_uk, label: 'Allowed Time UK'
  filter :allowed_time_sg, label: 'Allowed Time SG'
  filter :time_unit
  filter :expected_delivery_time_uk, label: 'Expected Delivery Time UK (in days)'
  filter :expected_delivery_time_sg, label: 'Expected Delivery Time SG (in days)'

  form do |f|
    inputs 'Details' do
      input :state, as: :select, collection: LineItem.state_machine.states.map(&:name)
      input :from_event, as: :select, collection: StatesTimeline::ALLOWED_EVENTS
      input(:allowed_time_uk, label: 'Allowed Time UK')
      input(:allowed_time_sg, label: 'Allowed Time SG')
      input :time_unit
      input(:expected_delivery_time_uk, label: 'Expected Delivery Time UK (in days)')
      input(:expected_delivery_time_sg, label: 'Expected Delivery Time SG (in days)')
    end
    inputs 'Sales Location Details' do
      has_many :sales_location_timelines, allow_destroy: true, new_record: true do |t|
        t.input :sales_location
        t.input :allowed_time
        t.input :expected_delivery_time
      end
    end
    actions
  end

  index do
    column :state
    column :from_event
    column :time_unit
    column('Sales Locations Timelines') do |states_timeline|
      states_timeline.formatted_sales_location_info_html
    end
    column :created_at
    actions
  end

  sidebar 'Sales Location Timelines', only: [:show] do
    attributes_table_for states_timeline.sales_location_timelines do
      row :sales_location
      row :allowed_time
      row :expected_delivery_time
    end
  end

  controller do
    def scoped_collection
      super.includes(sales_location_timelines: :sales_location)
    end
  end
end
