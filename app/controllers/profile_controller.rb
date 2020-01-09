class ProfileController < ApplicationController
  respond_to :html, :json, :js

  def create
    @profile = Profiles::Manager.new(
      params: params,
      user: current_user,
      profile_params: profile_params
    ).create_or_update

    respond_with @profile
  end

  def edit
    @customer     = Customer.includes(profile: [measurements: [:alterations, category_param: [:category, :param, values: [:value]]]]).find_by(id: params[:customer_id])
    @outfitter    = current_user.decorate
    @profile      = @customer.profile
    @summary      = AlterationSummary.new
    @categories   = Category.all.select(:name, :id, :order, :visible).order(:order)
    @category_ids = @categories.map(&:id)
    @item_params  = LineItems::Helper.form_alteration_params(item_ids: params[:line_item_id])
    @params       = Measurements::Builder.params(category_ids: @category_ids)
    @checks       = MeasurementCheck.all.select(:id, :category_param_id, :min, :max,
                                                :percentile_of, :calculations_type)
                                    .group_by(&:category_param_id)

    Measurements::Builder.build_alterations(object: @customer.profile)
    @available_categories = @profile.measurements.joins(category_param: :category).pluck('categories.name', 'categories.id').uniq
    @customer, @profile   = @customer.decorate, @profile.decorate
    @request_url          = request.referrer
    @without_extra_fields = params[:without_extra_fields]
    @profile_categories = @profile.categories.each_with_object({}) { |p_c, response| response[p_c.category_id] = p_c  }

    render 'profile/edit/edit'
  end

  def update
    @profile = Profiles::Manager.new(
      params: params,
      user: current_user,
      profile_params: profile_params
    ).create_or_update
    path = params[:new_measurement] == 'true' ? 'profile/create' : 'profile/edit/update'

    render path
  end

  def alter
    response = Profiles::Alteration.perform(
      params,
      profile_params,
      current_user,
      nil
    )
    @profile          = response[:profile]
    @summary          = response[:summary]
    @requested_action = params[:requested_action].parameterize.underscore
    @request_url      = params[:request_url]
    @no_pdf_sheet     = maybe_no_pdf?

    render 'alteration_summaries/update'
  end

  def destroy
    profile = Profile.find_by(customer_id: params[:customer_id])

    if profile
      profile.destroy
      profile.customer.comments.destroy_all
    end

    flash[:notice] = 'Profile was successfully detached. This customer have no profile now.'

    redirect_to customer_path(id: params[:customer_id])
  end

  def items
    @customer     = Customer.with_includes.find_by(id: params[:customer_id])
    @profile      = @customer.profile&.decorate || @customer.build_profile.decorate
    @params       = Measurements::Builder.params(category_ids: params[:category_ids])
    @checks       = MeasurementCheck.all.select(:id, :category_param_id, :min, :max,
                                                :percentile_of, :calculations_type)
                                    .group_by(&:category_param_id)
    @infos        = @profile.alteration_infos.to_a
    @review       = ActiveRecord::Type::Boolean.new.type_cast_from_user(params[:review])
    @categories   = Category.where(id: params[:category_ids]).select(:id, :name, :order).order(:order)
    @selected_ids = params[:category_ids].to_a.map(&:to_i)
    @existing_ids = params[:existing_ids].to_a.map(&:to_i).uniq
    @comments     = @customer.comments.order(body: :desc)
    @categories_hash = @customer.profile.categories.each_with_object({}) { |category, hash| hash[category.category_id] = category.status }
    @non_adjustable_items = @customer.decorate.non_adjustable_items
    @profile_categories = @profile.categories.each_with_object({}) { |p_c, response| response[p_c.category_id] = p_c  }
    @fits             = @profile.fits.select(:category_id, :with_fitting_garment).each_with_object({}) { |fit, fits| fits[fit.category_id] = fit.with_fitting_garment }
    Measurements::Builder.build_measurements(object: @customer.profile, category_ids: params[:category_ids])
    @customer.profile.images.build

    respond_with @profile
  end

  private

  def profile_params
    params.require(:profile).permit(
      :id, :submitted, :customer_id, :author_id, :submitter_id,
      measurements_attributes: [:id, :value, :allowance, :adjustment,
        :final_garment, :category_param_value_id, :category_param_id,
        :post_alter_garment, :adjustment_value_id, :fitting_garment_value,
        :fitting_garment_changes, :fitting_garment_measurement_id,
        error_confirmation_attributes: [:id, :confirmed],
        alterations_attributes: [:id, :number, :value, :author_id, :measurement_id, :category_param_value_id, :category_id, :alteration_summary_id]],
      images_attributes: [:id, :image, :image_cache, :category_param_value_id]
    )
  end

  def maybe_no_pdf?
    ActiveRecord::Type::Boolean.new.type_cast_from_database(params[:without_extra_fields])
  end
end
