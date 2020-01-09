class Api::AccountingsController < Api::ApplicationController
  before_action :add_origin_header, only: [:index]
  before_action :authenticate

  respond_to :json

  def index
    @q                = LineItem.joins(:order)
                                .includes(:product, :real_cog, :sales_person, :sales_location, :fabrics, order: [:customer, :billing, :shipping])
                                .all
                                .ransack(params[:q])
    @q.sorts          = sorting_order
    results           = @q.result.page(params[:page]).per(per_page)
    @accountings      = AccountingDecorator.decorate_collection(results)
    @sales_persons    = User.all.pluck(:id, :first_name, :last_name).map { |array| [array[0], "#{array[1]} #{array[2]}"]}
    @sales_locations  = SalesLocation.all.pluck(:id, :name)
    @tailors          = AlterationTailor.select(:id, :name).all
    @couriers         = CourierCompany.select(:id, :name).all
    @vat_rates        = VatRate.all
    @estimated_cogs   = EstimatedCog.all
    @fx_rates         = FxRate.all

    respond_with @accountings
  end

  private

  def per_page
    params[:per_page] || 40
  end

  def sorting_order
    return 'created_at desc' unless params[:order]

    splitted_params = params[:order].split('_')

    sort_order = splitted_params.pop
    sort_column = splitted_params.join('_')

    "#{sort_column} #{sort_order}"
  end
end
