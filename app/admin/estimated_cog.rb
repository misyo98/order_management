ActiveAdmin.register EstimatedCog do
  menu parent: 'Accountings', label: 'Estimated COGS', if: -> { can? :index, EstimatedCog }

  active_admin_import

  permit_params :country, :category, :canvas, :cmt, :fabric_consumption, :estimated_inbound_shipping_costs, :estimated_duty, :valid_from

  csv do
    column('ID', humanize_name: false) { |cog| cog.id }
    column('Country', humanize_name: false) { |cog| cog.country }
    column('Category', humanize_name: false) { |cog| cog.category }
    column('Canvas', humanize_name: false) { |cog| cog.canvas }
    column('CMT (USD)', humanize_name: false) { |cog| cog.cmt }
    column('Fabric Consumption (m)', humanize_name: false) { |cog| cog.fabric_consumption }
    column('Inbound shipping costs (estimated) USD', humanize_name: false) { |cog| cog.estimated_inbound_shipping_costs }
    column('Duty (estimated) USD', humanize_name: false) { |cog| cog.estimated_duty }
    column('Valid From', humanize_name: false) { |cog| cog.valid_from }
  end

  form do |f|
    inputs 'Details' do
      input :country, as: :select, collection: ['SG', 'GB']
      input :category, as: :select, collection: EstimatedCog::CATEGORIES
      input :canvas, as: :select, collection: EstimatedCog::CANVAS_OPTIONS
      input :cmt, label: 'CMT (USD)'
      input :fabric_consumption, label: 'Fabric Consumption (m)'
      input :estimated_inbound_shipping_costs, label: 'Inbound shipping costs (estimated) USD'
      input :estimated_duty, label: 'Duty (estimated) USD'
      input :valid_from, as: :datepicker
    end
    actions
  end

  index title: 'Estimated COGS', download_links: -> { can?(:download_csv, EstimatedCog) } do
    id_column
    column('Country', humanize_name: false) { |cog| cog.country }
    column('Category', humanize_name: false) { |cog| cog.category }
    column('Canvas', humanize_name: false) { |cog| cog.canvas }
    column('CMT (USD)', humanize_name: false) { |cog| cog.cmt }
    column('Fabric Consumption (m)', humanize_name: false) { |cog| cog.fabric_consumption }
    column('Inbound shipping costs (estimated) USD', humanize_name: false) { |cog| cog.estimated_inbound_shipping_costs }
    column('Duty (estimated) USD', humanize_name: false) { |cog| cog.estimated_duty }
    column('Valid From', humanize_name: false) { |cog| cog.valid_from }
    actions
  end

  controller do
    def do_import
      response = Importers::Objects::EstimatedCogs.new(file: params[:active_admin_import_model][:file]).call
      if response.success?
        flash[:notice] = I18n.t(:updated_item, count: response.count)
      else
        flash[:alert]  = response.error
      end

      redirect_to estimated_cogs_path
    end
  end

end
