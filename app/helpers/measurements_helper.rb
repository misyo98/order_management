# frozen_string_literal: true

module MeasurementsHelper

  MEASUREMENT_CLASSES   = %w(form-control user-input measurements-input calculatable).freeze
  ADJUSTMENT_CLASSES    = %W(form-control user-input calculatable-adjustments).freeze
  CHECK_CLASSES         = %w(checks).freeze
  UNREQUIRED_IDS        = %w(measurement_waistcoat_waistcoat_front_length_straight
                          measurement_waistcoat_waistcoat_1st_button_position
                          measurement_overcoat_button_position).freeze
  SUBMIT_BUTTON_CLASSES = %w(btn btn-outline-primary btn-lg new_line submit-at-bottom).freeze
  FITTING_GARMENT_MEASUREMENT_CLASSES = %w(form-control user-input measurements-input fitting-garment-calculatable calculatable).freeze
  FITTING_GARMENT_ADJUSTMENT_CLASSES = %W(form-control user-input fitting-garment-calculatable-adjustments calculatable).freeze

  def measurement_partial(id)
    category_param(id).param.digits? ? 'digits_item' : 'values_item'
  end

  def category_name(id)
    category_param = category_param(id)
    category_param(id).category.name if category_param.category.visible
  end

  def param_title(id)
    category_param(id).param.title
  end

  def measurement_field(form, with_fitting_garment = false)
    category_param = category_param(form.object.category_param_id)
    form.text_field :value, name: name(attribute: :value, id: form.object.category_param_id), class: input_classes(@checks[category_param.id]), id: measurement_id(category_param),
      required: !measurement_id(category_param).in?(UNREQUIRED_IDS), step: :any, disabled: should_be_disabled?(form.object), readonly: measurement_readonly?(form.object, with_fitting_garment),
      data: { category: form.object.category_param.category_id }
  end

  def allowance_field(form, with_fitting_garment = false)
    category_param = category_param(form.object.category_param_id)
    form.text_field :allowance, name: name(attribute: :allowance, id: form.object.category_param_id), class: 'form-control allowances', id: allowance_id(category_param),
      data: allowances(category_param&.allowance), step: :any, readonly: current_user.admin? || with_fitting_garment,
      disabled: should_be_disabled?(form.object)
  end

  def adjustment_field(form)
    category_param = category_param(form.object.category_param_id)
    form.text_field :adjustment, name: name(attribute: :adjustment, id: form.object.category_param_id), class: ADJUSTMENT_CLASSES, id: adjustment_id(category_param),
      step: :any, disabled: should_be_disabled?(form.object) || disabled_for_not_pending?(form.object), readonly: adjustment_readonly?(form.object), data: { default_adjustment: form.object.adjustment }
  end

  def adjustment_value_field(form)
    category_param = category_param(form.object.category_param_id)
    form.select :adjustment_value_id, values_collection(category_param), { selected: adjustment_dropdown_value(form: form) },
      name: name(attribute: :adjustment_value_id, id: form.object.category_param_id),
      class: 'form-control adjustment-value', id: value_id(category_param), disabled: @infos.size > 0
  end

  def garment_field(form, with_fitting_garment = false)
    category_param = category_param(form.object.category_param_id)
    form.text_field :final_garment, name: name(attribute: :final_garment, id: form.object.category_param_id),
      class: 'form-control final-garments', id: garment_id(category_param), data: { init_value: form.object.final_garment, category: form.object.category_param.category_id },
      step: :any, disabled: should_be_disabled?(form.object), readonly: measurement_readonly?(form.object, with_fitting_garment)
  end

  def garment_or_final_garment_field(form, with_fitting_garment = false)
    if should_be_disabled?(form.object)
      pseudo_final_garment_field(form)
    else
      garment_field(form, with_fitting_garment)
    end
  end

  def pseudo_final_garment_field(form)
    category_param = category_param(form.object.category_param_id)
    form.text_field :post_alter_garment, name: name(attribute: :final_garment, id: form.object.category_param_id),
      class: 'form-control final-garments post-alteration-garment', id: garment_id(category_param),
      data: { init_value: form.object.post_alter_garment }, step: :any, disabled: true
  end

  def category_param_value_field(form)
    category_param = category_param(form.object.category_param_id)
    form.select :category_param_value_id, values_collection(category_param), {}, name: name(attribute: :category_param_value_id, id: form.object.category_param_id),
      class: 'form-control calculatable', id: value_id(category_param), disabled: should_be_disabled?(form.object), readonly: measurement_readonly?(form.object),
      data: { value: values_collection(category_param).first[1] }
  end

  def alter_field(form, parent_form)
    disabled = disabled?(form.object, parent_form.object)
    category_param = category_param(parent_form.object.category_param_id)
    form.text_field(:value, value: default_value(value: form.object.value),
      class: input_alteration_classes(disabled: disabled) << 'alteration-value', id: alteration_id(category_param),
      step: :any, disabled: disabled_default, readonly: if_heigth_inches?(object: parent_form.object))
  end

  def alter_value_field(form, parent_form)
    form.select :category_param_value_id, values_collection(parent_form.object.category_param), { selected: alteration_value_selected_id(parent: parent_form.object) },
      class: 'form-control alteration-value', disabled: disabled_default
  end

  def alter_author_field(form, parent_form)
    disabled = disabled?(form.object, parent_form.object)
    form.hidden_field :author_id, value: @outfitter.id, disabled: disabled_default,
      class: input_alteration_classes(disabled: disabled)
  end

  def alter_measurement_field(form, parent_form)
    disabled = disabled?(form.object, parent_form.object)
    form.hidden_field :measurement_id, disabled: disabled_default, class: input_alteration_classes(disabled: disabled)
  end

  def alter_category_id_field(form, parent_form)
    disabled = disabled?(form.object, parent_form.object)
    form.hidden_field :category_id, value: parent_form.object.category_id, disabled: disabled_default, class: input_alteration_classes(disabled: disabled)
  end

  def check_html_data(form)
    category_param = category_param(form.object.category_param_id)
    check = @checks[category_param.id]
    { min: category_param.min, max: category_param.max, name: check_name(check&.first), category_param_id: category_param.id }
  end

  def submission_check_html_data(form)
    category_param = submission_category_param(form.category_param_id)
    check = @checks[category_param.id]
    { min: category_param.min, max: category_param.max, name: check_name(check&.first), category_param_id: category_param.id }
  end

  def check_classes(check, classes = CHECK_CLASSES.dup)
    classes << :checkable if check&.first&.percentile?
    classes << :full_values if check&.first&.abs_value?
    classes
  end

  def items_classes
    :hidden unless @customer
  end

  def check_html(check)
    return unless check
    check = check.first

    if check.abs_value?
      "<span class='min-max-val'> Min: #{check.min} <br/> Max: #{check.max} <br/></span>".html_safe
    else
      "<span class='min-max-val'>Min: <br/> Max:</span>".html_safe
    end
  end

  def detect_alteration_val(collection, summary_id)
    alteration = collection.detect { |element| element.alteration_summary_id == summary_id }
    alteration.present? ? alteration.value.to_f : 0
  end

  def check_name(check)
    return unless check

    case
      when check.height?          then :garment_height_height_inches
      when check.chest?           then :garment_jacket_chest
      when check.shirt_chest?     then :garment_shirt_chest
      when check.knee?            then :garment_pants_knee
      when check.chinos_thigh?    then :garment_chinos_thigh
      when check.thigh?           then :garment_pants_thigh
    end
  end

  def resolve_header_class(header)
    header == 'body' ? "#{header} hidden" : header.parameterize.underscore
  end

  def category_param(id)
    @params.detect { |param| param.id == id }
  end

  # private

  def name(attribute:, id:)
    "profile[measurements_attributes][#{id}][#{attribute}]"
  end

  def disabled?(alteration, measurement)
    alteration.persisted? || @profile_categories[measurement.category_param.category_id].unsubmitted_status?
  end

  def measurement_readonly?(object, with_fitting_garment = false)
    object.persisted? && (@review || !@profile_categories[object.category_param.category_id].unsubmitted_status?)
  end

  def adjustment_readonly?(object)
    @categories_hash[object.category.id] == 'confirmed'
  end

  def should_be_disabled?(object)
    object.persisted? && !@profile_categories[object.category_param.category_id].unsubmitted_status? && object.alterations.any?
  end

  def disabled_for_not_pending?(object)
    return false unless @non_adjustable_items.any?

    @non_adjustable_items.include?(object.category_param.category_name)
  end

  def disabled_default
    true
  end

  def default_value(value:)
    value == 0 ? nil : value
  end

  def if_heigth_inches?(object:)
    object.param_title == 'Height (inches)'
  end

  def alteration_value_selected_id(parent:)
    alterations_count = parent.alterations.size - 1

    case
    when alterations_count == 0 && parent.adjustment_value_id
      parent.adjustment_value_id
    when alterations_count > 0
      parent.alterations.select(&:persisted?).last.category_param_value_id
    else
      parent.category_param_value_id
    end
  end

  def adjustment_dropdown_value(form:)
    form.object.adjustment_value_id ? form.object.adjustment_value_id : form.object.category_param_value_id
  end

  def category_param(id)
    @params.detect { |param| param.id == id }
  end

  def submission_category_param(id)
    @measurement_params.detect { |param| param.id == id }
  end

  def measurement_id(category_param)
    "measurement_#{category_to_id(category_param)}_#{param_to_id(category_param)}"
  end

  def allowance_id(category_param)
    "allowance_#{category_to_id(category_param)}_#{param_to_id(category_param)}"
  end

  def fitting_garment_value_id(category_param)
    "fitting_garment_value_#{category_to_id(category_param)}_#{param_to_id(category_param)}"
  end

  def fitting_garment_changes_id(category_param)
    "fitting_garment_changes_#{category_to_id(category_param)}_#{param_to_id(category_param)}"
  end

  def adjustment_id(category_param)
    "adjustment_#{category_to_id(category_param)}_#{param_to_id(category_param)}"
  end

  def garment_id(category_param)
    "garment_#{category_to_id(category_param)}_#{param_to_id(category_param)}"
  end

  def post_alter_garment_id(category_param)
    "post_alter_garment_#{category_to_id(category_param)}_#{param_to_id(category_param)}"
  end

  def value_id(category_param)
    "value_#{category_to_id(category_param)}_#{param_to_id(category_param)}"
  end

  def adustment_value_id(category_param)
    "adjustment_value_#{category_to_id(category_param)}_#{param_to_id(category_param)}"
  end

  def alteration_id(category_param)
    "alteration_#{category_to_id(category_param)}_#{param_to_id(category_param)}"
  end

  def values_collection(category_param)
    category_param.values.collect { |obj| [obj.value.title, obj.id] }
  end

  def input_classes(check, classes = MEASUREMENT_CLASSES.dup)
    classes << :with_min_max if check
    classes
  end

  def category_to_id(object)
    object.category.name.parameterize.underscore
  end

  def param_to_id(object)
    object.param.alias.parameterize.underscore
  end

  def allowances(allowance)
    return unless allowance
    { slim: allowance.slim, singapore_slim: allowance.singapore_slim,
      classic: allowance.classic, regular: allowance.regular,
      self_slim: allowance.self_slim, self_regular: allowance.self_regular }
  end

  def input_alteration_classes(disabled: false)
    classes = %w(form-control alteration)
    classes << 'disabled_input' if disabled
    classes
  end
end
