module FitsHelper
  def fit_label(form)
    form.label category(form.object.category_id).name, nil, class:'col-sm-2 form-check-label'
  end

  def fit_visibility(form)
    "display:#{ category(form.object.category_id).visible ? '' : 'none' };".html_safe
  end

  def category_check_box(form)
    category = category(form.object.category_id)
    form.check_box :checked, { class: ['form-check-input', 'category-checkboxes', (@review || form.object.checked?) && 'unclickable'] }, category.id
  end

  def fit_select(form)
    category = category(form.object.category_id)
    form.select :fit, fit_collection(category), { selected: default_fit(form.object) }, id: select_fit_id(category), readonly: form.object.checked?, class: 'fits'
  end

  def unchangeable_categories(profile)
    profile.categories.each_with_object({}) do |category, response|
      if category.submitted? || category.confirmed?
        response[category.category_name] = category.category_id
      end
    end
  end

  def select_fit_id(category)
    "#{category.name.parameterize.underscore}_fit"
  end

  private

  def category(id)
    @categories.detect { |category| category.id == id }
  end

  def fit_collection(category)
    fits = Fit.fits.keys.to_a.reject { |element| element == 'classic' && category.name != 'Shirt' }
    fits.map do |fit|
      fit_name =
        if category.name == 'Shirt' && fit == 'regular'
          'Tailored'
        else
          fit.humanize
        end

      [fit_name, fit]
    end
  end

  def default_fit(fit)
    if fit.persisted? && fit.checked
      fit.fit
    else
      @country == 'SG' ? 'singapore_slim' : 'slim'
    end
  end
end
