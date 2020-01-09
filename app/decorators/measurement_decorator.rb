class MeasurementDecorator < Draper::Decorator
  delegate_all
  decorates_association :alterations

  FULL_HEADERS = ['Category', 'Measurement', 'Body (inches)', 'Allowances',
                    'Adjustments during check', 'Final Garment',
                    'Measurement Check', 'Issues'].freeze
  RESTRICTED_HEADERS = (FULL_HEADERS.dup - ['Adjustments during check']).freeze
  BODY_POSITION_HEADERS = ['Category', 'Measurement' , 'Body (inches)', 'Measurement Check', 'Issues'].freeze
  BODY_POSITION_WITH_SUBMIT = ['Category', 'Measurement', 'Body (inches)', 'Adjustments during check', 'Measurement Check', 'Issues'].freeze
  FITTING_GARMENT_FULL_HEADERS = [
    'Category', 'Measurement', 'Body (inches)', 'Allowances',
    'Fitting Garment', 'Changes +/-', 'Adjustments during check', 'Final Garment',
    'Measurement Check', 'Issues'
  ].freeze
  FITTING_GARMENT_RESTRICTED_HEADERS = (FITTING_GARMENT_FULL_HEADERS.dup - ['Adjustments during check']).freeze

  def measurement_field
    category_param_value_id? ? category_param_value.value_title : model.value
  end

  def allowance_field
    category_param_value_id? ? '' : allowance
  end

  def adjustment_field
    adjustment_value_id? ? adjustment_value.value_title : adjustment_default_value
  end

  def final_garment_field
    @final_garment_field ||=
      case
      when adjustment_value_id     then adjustment_value.value_title
      when category_param_value_id then category_param_value.value_title
      else final_garment
      end
  end

  def final_garment_form_field(form)
    form.text_field :final_garment, class: 'form-control garment alteration-calculatable', id: h.garment_id(category_param), step: :any, readonly: true
  end

  def category_field
    h.content_tag(:span, category_name, class: "#{category_name.parameterize.underscore}")
  end

  def param_field
    param_title
  end

  def value_field(form)
    form.select :category_param_value_id, h.values_collection(category_param), {}, class: select_value_classes, id: h.value_id(category_param), disabled: true
  end

  def post_alter_garment_field
    alteration = alterations.last

    if alteration
      alteration.category_param_value_id ? alteration.value_field : post_alter_garment
    else
      final_garment_field
    end
  end

  def post_alter_garment_form_field(form, profile, alteration_value = 0)
    form.text_field :post_alter_garment, value: default_value(profile), class: 'form-control post-alter-garment', id: h.post_alter_garment_id(category_param), step: :any,
      readonly: true, data: { 'default-value' => (default_value(profile)&.-(alteration_value)) }
  end

  def blank_alterations(infos_count:, profile:)
    return profile.max_alterations unless infos_count
    if infos_count > alterations.count
      profile.max_alterations - alterations.count
    elsif profile.max_alterations == alterations.count
      0
    else
      profile.max_alterations - infos_count
    end
  end

  def partial
    param.digits? ? 'profile/edit/digits_item' : 'profile/edit/values_item'
  end

  def alteration_partial
    param.digits? ? 'alteration_summaries/digits_item' : 'alteration_summaries/values_item'
  end

  def check_html_data(check)
    return unless check
    { min: check.min, max: check.max, name: h.check_name(check) }
  end

  class << self
    def resolve_headers(review:, category:)
      case
      when h.reviewable?(review_action: review) && category.name == 'Body shape & postures'
        BODY_POSITION_WITH_SUBMIT
      when !h.reviewable?(review_action: review) && category.name == 'Body shape & postures'
        BODY_POSITION_HEADERS
      when h.reviewable?(review_action: review)
        FITTING_GARMENT_FULL_HEADERS
      else
        FITTING_GARMENT_RESTRICTED_HEADERS
      end
    end
  end

  private

  def default_value(profile)
    if alterations.size == alterations.select(&:persisted?).size
      alterations.size >= 1 ? post_alter_garment : final_garment
    else
      alterations.size > 1 ? post_alter_garment : final_garment
    end
  end

  def adjustment_default_value
    adjustment == 0 ? nil : adjustment
  end

  def select_value_classes
    classes = ['form-control']
    classes << 'disabled_input' if persisted?
    classes
  end
end
