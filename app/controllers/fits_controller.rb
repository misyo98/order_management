class FitsController < ApplicationController
  respond_to :html, :js

  def create
    convert_checks
    @customer = Customer.find_by(id: params[:customer_id])

    @customer.profile.update(fit_params)

    flash[:notice] = 'Profile successfully created!'
  end

  private

  def fit_params
    params.require(:profile).permit(fits_attributes: %i(id category_id customer_id fit checked with_fitting_garment))
  end

  def convert_checks
    params[:profile][:fits_attributes] = Fits::CheckBoxConverter.convert(params: params[:profile][:fits_attributes])
  end
end
