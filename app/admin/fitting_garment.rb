ActiveAdmin.register FittingGarment do
  COUNTRIES = ['SG', 'GB'].freeze

  menu parent: 'Settings', if: -> { current_user.admin? }

  config.sort_order = 'category_id_asc'

  filter :name_cont, label: 'Name', as: :string
  filter :category_id_eq, as: :select, collection: Category.visible.pluck(:name, :id), label: 'Category'
  filter :country_eq, as: :select, collection: COUNTRIES, label: 'Country'


  permit_params :category_id, :name, :order, :country,
                fitting_garment_measurements_attributes: %i[id fitting_garment_id category_param_id value]

  form do |f|
    tabs do
      tab 'General' do
        inputs do
          input :name
          input :order
          input :country, as: :select, collection: COUNTRIES
          input :category, input_html: { disabled: f.object.persisted? }
        end
      end
      if f.object.persisted?
        tab 'Measurements' do
          has_many :fitting_garment_measurements, new_record: false do |t|
            t.input :category_param, input_html: { disabled: true }
            t.input :value
          end
          hr
        end
      end
    end
    actions
  end

  index download_links: -> { can?(:download_csv, FittingGarment) } do
    render 'fitting_garments/import_result'

    selectable_column
    column :id
    column :name
    column :order
    column :category
    column :country
    column :created_at
    column :updated_at
    actions
  end

  collection_action :download_csv, method: :get

  action_item :download_csv, only: :index, if: proc { can? :crud, FittingGarment } do
    link_to 'Download CSV', download_csv_fitting_garments_path
  end

  active_admin_import

  controller do
    def create
      @fitting_garment = FittingGarments::Creator.create(permitted_params[:fitting_garment])

      if @fitting_garment.persisted?
        redirect_to edit_fitting_garment_path(@fitting_garment)
      else
        render :new
      end
    end

    def show
      @category_param_id = params[:category_param_id]
      @fitting_garment = FittingGarment.find_by(id: params[:id])

      render :show
    end

    def index
      @category_param_id = params[:category_param_id]

      respond_to do |format|
        format.html { super }
        format.js do
          @fitting_garments = FittingGarment.where(country: [current_user.country, nil]).order(category_id: :asc).ransack(params[:q]).result
          render :index
        end
      end
    end

    def download_csv
      file = Exporters::Objects::FittingGarments.new().call

      send_data file, filename: "fitting-garments-#{Date.today}.csv"
    end

    def do_import
      if params[:active_admin_import_model]
        ImportFittingGarments.perform_async(Base64.encode64(File.read params[:active_admin_import_model][:file].path))

        redirect_to fitting_garments_path, notice: 'Fitting Garments being imported in the background!'
      else
        redirect_to :back, alert: 'Please attach a CSV file.'
      end
    end
  end
end
