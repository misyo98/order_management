ActiveAdmin.register RealCog do
  menu parent: "Accountings", label: 'Real COGS', if: -> { can? :index, RealCog }

  active_admin_import

  permit_params %i(manufacturer_id order_number name country product_rc cost_bucket cost_bucket_id
                   construction meters fabric product_group cogs_rc_usd order_date deal_date valid_from)

  filter :order_number
  filter :manufacturer_id

  csv do
    column('Manufacturer ID', humanize_name: false) { |cog| cog.manufacturer_id }
    column('Order No.', humanize_name: false) { |cog| cog.order_number }
    column('Name', humanize_name: false) { |cog| cog.name }
    column('Country', humanize_name: false) { |cog| cog.country }
    column('Product RC', humanize_name: false) { |cog| cog.product_rc }
    column('Construction', humanize_name: false) { |cog| cog.construction }
    column('Meters', humanize_name: false) { |cog| cog.meters }
    column('Fabric', humanize_name: false) { |cog| cog.fabric }
    column('Product Group', humanize_name: false) { |cog| cog.product_group }
    column('COGS RC USD', humanize_name: false) { |cog| cog.cogs_rc_usd }
    column('Order Date', humanize_name: false) { |cog| cog.order_date }
    column('Deal date', humanize_name: false) { |cog| cog.deal_date }
  end

  form do |f|
    inputs 'Details' do
      input :manufacturer_id, label: 'Manufacturer ID'
      input :order_number
      input :name
      input :country, as: :select, collection: ApplicationHelper::COUNTRIES_FOR_SELECT
      input :product_rc, label: 'Product RC'
      input :construction
      input :meters
      input :fabric
      input :product_group
      input :cogs_rc_usd, label: 'COGS RC USD'
      input :order_date, as: :datepicker
      input :deal_date, as: :datepicker
    end
    actions
  end

  index title: 'Real COGS', download_links: -> { can?(:download_csv, RealCog) } do
    id_column
    column('Manufacturer ID', humanize_name: false) { |cog| cog.manufacturer_id } 
    column('Order Number', humanize_name: false) { |cog| cog.order_number }
    column('Name', humanize_name: false) { |cog| cog.name }
    column('Country', humanize_name: false) { |cog| cog.country }
    column('Product RC', humanize_name: false) { |cog| cog.product_rc }
    column('Construction', humanize_name: false) { |cog| cog.construction }
    column('Meters', humanize_name: false) { |cog| cog.meters }
    column('Fabric', humanize_name: false) { |cog| cog.fabric }
    column('Product Group', humanize_name: false) { |cog| cog.product_group }
    column('COGS RC USD', humanize_name: false) { |cog| cog.cogs_rc_usd }
    column('Order Date', humanize_name: false) { |cog| cog.order_date }
    column('Deal date', humanize_name: false) { |cog| cog.deal_date }
    actions
  end

  controller do
    def do_import
      response = Importers::Objects::RealCogs.new(file: params[:active_admin_import_model][:file]).call
      if response.success?
        flash[:notice] = I18n.t(:updated_item, count: response.count)
      else
        flash[:alert]  = response.error
      end

      redirect_to real_cogs_path
    end
  end

end
