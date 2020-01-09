$.default_calculation_measurements = [
  'shirt_neck', 'shirt_waist', 'shirt_shoulder', 'shirt_shirt_sleeve_length', 'shirt_wrist_cuff_with_watch',
  'shirt_shirt_sleeve_length_right_sleeve', 'shirt_shirt_sleeve_length_left_sleeve',
  'jacket_jacket_sleeve_length', 'jacket_shoulder', 'jacket_jacket_length_back', 'jacket_jacket_sleeve_length_left_sleeve',
  'jacket_jacket_sleeve_length_right_sleeve', 'pants_pant_waist',
  'chinos_pant_waist', 'chinos_rise', 'waistcoat_waistcoat_chest',
  'waistcoat_waist_button_position','waistcoat_waist_belly_button', 'waistcoat_waistcoat_front_length_pointed',
  'waistcoat_waistcoat_front_length_straight', 'waistcoat_waistcoat_back_length',
  'waistcoat_waistcoat_1st_button_position', 'overcoat_neck', 'overcoat_chest',
  'overcoat_waist', 'overcoat_shoulder', 'overcoat_biceps', 'overcoat_overcoat_sleeve_length', 'overcoat_overcoat_sleeve_length_right_sleeve',
  'overcoat_overcoat_front_length', 'overcoat_overcoat_sleeve_length_left_sleeve',
  'overcoat_overcoat_back_length', 'overcoat_button_position', 'shirt_shirt_length_back_tuck_in', 'shirt_shirt_length_front_tuck_out',
  'shirt_shirt_length_back_tuck_out', 'shirt_waist_button_position', 'jacket_waist_button_position', 'shirt_wrist_cuff_button_cuff_with_watch',
  'shirt_wrist_cuff_french_cuff_with_watch', 'shirt_wrist_cuff_french_cuff_without_watch', 'pants_hip_pants_with_pleats', 'chinos_hip_pants_with_pleats',
  'pants_chino_outseam', 'pants_chino_outseam_left_leg', 'pants_chino_outseam_right_leg'
]

$(document).ready ->
  $('body').on 'change', '#value_body_shape_postures_prominent_chest', ->
    if $(this).hasClass('adjustment-value')
      $.methods.addProminentChestWarning()
      return

    if confirm("Warning! Changing this value will cause recalculation of some of the measurements. Make sure that everything is correct after changing this body position.")
      $.calculations.general($('#measurement_jacket_neck'), false, true)
      $.calculations.general($('#measurement_jacket_chest'), false, true)
      $(this).attr('data-value', $(this).val())
      $.methods.addProminentChestWarning()
    else
      $(this).val($(this).attr('data-value'))

  $('body').on 'change', '#value_body_shape_postures_body_type', ->
    return if $(this).hasClass('adjustment-value')
    if confirm("Warning! Changing this value will cause recalculation of some of the measurements. Make sure that everything is correct after changing this body position.")
      $.calculations.general($('#measurement_shirt_biceps'), false, true)
      $.calculations.general($('#measurement_jacket_chest'), false, true)
      $.calculations.general($('#measurement_jacket_button_position_2_buttons'), false, true)
      $(this).attr('data-value', $(this).val())
    else
      $(this).val($(this).attr('data-value'))


  #default trigger for all form measurement calculations
  $('body').on 'change', '.calculatable', () ->
    return if $(this).attr('readonly') || $(this).attr('disabled')
    $.calculations.general($(this))
    present_fitting_garment = $(this).closest('tr').find('.fitting-garment-value')
    fitting_garment_value = $(this).closest('tr').find('.fitting-garment-changes')

    $.fitting_garments.calculate_change(fitting_garment_value) if present_fitting_garment.val() != ''

  $('body').on 'blur', '.calculatable', () ->
    return if $(this).attr('readonly') || $(this).attr('disabled')

    $.custom_validations.validate_with_dependencies(
      $('.measurement-form').serializeFormJSON(),
      $('#fit-form').serializeFormJSON(),
      $(this).closest('tr').attr('data-category-param-id')
    )

  $('body').on 'change', '.alteration-value, .alteration', () ->
    $.custom_validations.validate_alteration(
      $('.measurement-form').serializeFormJSON(),
      $('#fit-form').serializeFormJSON(),
      $(this).closest('tr').attr('data-category-param-id'),
      $('#to_be_validated_summary_id').val()
    )

get_fit = (fit_name) ->
  fit = $('#' + fit_name).find('option:selected').val()
  if fit == 'singapore_slim'
    fit = 'singapore-slim'
  else if fit == 'self_slim'
    fit = 'self-slim'
  else if fit == 'self_regular'
    fit = 'self-regular'

  return fit

#function for calculating dynamically percentage for the measurements
$.calculate_percentage = (object, name, sibling) ->
  percentage = (parseFloat($('#garment_' + name).val()) / parseFloat($('#garment_'+ sibling).val()) * 100).toFixed(1)
  object.closest('tr').find('.percent').html(percentage + '%')

$.calculations =
  general: (object, allowance = false, mark_change = false) ->
    name = object.attr('id')
    return if name == undefined

    measurement = object

    if name.indexOf("measurement_") != -1
      name = name.replace(/measurement_/, '')
    else if name.indexOf("adjustment_") != -1
      name = name.replace(/adjustment_/, '')
      measurement = $('#measurement_' + name)

    fit_name = name.replace(/_.*/, '_fit')

    if name in $.default_calculation_measurements
      $.calculations.default(measurement, name, fit_name, allowance)
    else
      $.calculations[name](measurement, name, fit_name, allowance)

      $.custom_validations.validate_with_dependencies(
        $('.measurement-form').serializeFormJSON(),
        $('#fit-form').serializeFormJSON(),
        measurement.closest('tr').attr('data-category-param-id')
      )

    $.prefill.clearPrefillMessage($('#measurement_' + name))
    $.prefill.check_prefill(name, $('#measurement_' + name).val())

    if mark_change
      measurement.closest('td').addClass('info-td-msg')
      measurement.closest('td').append(
        "<span class='info-text-msg'>Measurement was recalculated based on new <b>Body type</b> selection</span>"
      )


  default: (obj, name, fit_name, allowance = false) ->
    fit = get_fit(fit_name)
    allowance ||= $('#allowance_' + name).data(fit)
    adjustment = $('#adjustment_' + name).val() || 0.0
    calculations = (parseFloat(obj.val()) + parseFloat(allowance) + parseFloat(adjustment)).toFixed(2)

    $('#garment_' + name).val(calculations)
    $('#allowance_' + name).val(allowance)

    fitting_garment = obj.closest('tr').find('.fitting-garment-value')
    change_input = obj.closest('tr').find('.fitting-garment-changes')

    $.fitting_garments.calculate_change(change_input) if fitting_garment.val() != ''

    if typeof $.validations[name] == 'function'
      $.validations[name]($('#garment_' + name))
    unless $.warningSiblings[name] == undefined
      $.calculate_percentage(obj, name, $.warningSiblings[name])

    $.custom_validations.validate_with_dependencies(
      $('.measurement-form').serializeFormJSON(),
      $('#fit-form').serializeFormJSON(),
      obj.closest('tr').attr('data-category-param-id')
    )

  height_height_inches: (obj, name, fit_name, allowance = false) ->
    adjustment = parseFloat($('#adjustment_' + name).val()) || 0.0
    this_val = parseFloat(obj.val())
    val_with_adjustment = this_val + adjustment
    $('#garment_' + name).val(val_with_adjustment)

    to_cm = Math.round(val_with_adjustment * 2.54)

    unless $('#adjustment_' + name).attr('readonly')
      $('#measurement_height_height_cm').val(to_cm)
      cm_adjustment = parseFloat($('#adjustment_height_height_cm').val()) || 0.0
      $('#garment_height_height_cm').val((parseFloat(to_cm) + parseFloat(cm_adjustment)).toFixed(2))

    $.methods.calculateChecks(val_with_adjustment, 'garment_height_height_inches')
    $.methods.calculateAbsChecks(val_with_adjustment, 'garment_height_height_inches')

  height_height_cm: (obj, name, fit_name, allowance = false) ->
    adjustment = parseFloat($('#adjustment_' + name).val()) || 0.0
    this_val = parseFloat(obj.val())
    val_with_adjustment = this_val + adjustment
    $('#garment_' + name).val(val_with_adjustment)

    to_inches = Math.round(val_with_adjustment / 2.54)
    $('#garment_height_height_inches').val(to_inches)

    if $('#adjustment_height_height_inches').attr('readonly')
      $('#adjustment_height_height_inches').val(parseFloat(to_inches) - parseFloat($('#measurement_height_height_inches').val()))
    else
      $('#measurement_height_height_inches').val((parseFloat(to_inches)).toFixed(2))

    $.methods.calculateChecks((parseFloat(to_inches)), 'garment_height_height_inches')
    $.methods.calculateAbsChecks((parseFloat(to_inches)), 'garment_height_height_inches')

  # SHIRT
  shirt_chest: (obj, name, fit_name, allowance = false) ->
    $.calculations.default(obj, name, fit_name, allowance)
    $.methods.calculateChecks($('#garment_shirt_chest').val(), 'garment_shirt_chest')
    $.calculations['shirt_waist_belly_button']($('#measurement_shirt_waist_belly_button'), 'shirt_waist_belly_button', 'shirt_fit')
    # $.validations['shirt_waist_belly_button']($('#garment_shirt_waist_belly_button'))

  shirt_waist_belly_button: (obj, name, fit_name, allowance = false) ->
    $.calculations.default(obj, name, fit_name, allowance)
    $.calculate_percentage(obj, name, 'shirt_chest')
    $.calculations['shirt_hip']($('#measurement_shirt_hip'), 'shirt_hip', 'shirt_fit')

  shirt_hip: (obj, name, fit_name, allowance = false) ->
    $.calculations.default(obj, name, fit_name, allowance)
    hip_garment = $('#garment_' + name)
    hip_measurement = $('#measurement_' + name)
    hip_garment_val = parseFloat(hip_garment.val())
    waist_garment_val = parseFloat($('#garment_shirt_waist_belly_button').val())

    if hip_garment_val < waist_garment_val
      $('#garment_' + name).val(waist_garment_val)
      new_allowance = (parseFloat(hip_garment.val()) - parseFloat(hip_measurement.val())).toFixed(2)
      $('#allowance_' + name).val(new_allowance)

  shirt_wrist_cuff_button_cuff_without_watch: (obj, name, fit_name, allowance = false) ->
    $.calculations.default(obj, name, fit_name, allowance)
    $('#measurement_shirt_wrist_cuff_button_cuff_with_watch').val(obj.val())
    $('#measurement_shirt_wrist_cuff_french_cuff_without_watch').val(obj.val())
    $('#measurement_shirt_wrist_cuff_french_cuff_with_watch').val(obj.val())


    $.calculations.default($('#measurement_shirt_wrist_cuff_button_cuff_with_watch'), 'shirt_wrist_cuff_button_cuff_with_watch', 'shirt_fit')
    $.calculations.default($('#measurement_shirt_wrist_cuff_french_cuff_without_watch'), 'shirt_wrist_cuff_french_cuff_without_watch', 'shirt_fit')
    $.calculations.default($('#measurement_shirt_wrist_cuff_french_cuff_with_watch'), 'shirt_wrist_cuff_french_cuff_with_watch', 'shirt_fit')


  shirt_biceps: (obj, name, fit_name, allowance = false) ->
    body_type = $('#value_body_shape_postures_body_type').find('option:selected').text().toLowerCase()
    fit = get_fit(fit_name)
    allowance ||= parseFloat($('#allowance_' + name).data(fit))
    body_measurement = parseFloat(obj.val())
    new_allowance =
      if body_measurement < 11
        parseFloat(allowance) + 0.25
      else if body_measurement > 16
        parseFloat(allowance) - 0.15
      else
        parseFloat(allowance)

    if body_type == 'muscular' && fit == 'slim' || body_type == 'muscular' && fit == 'singapore-slim'
      adjustment = $('#adjustment_' + name).val() || 0.0
      calculations = (body_measurement + new_allowance - 0.25 + parseFloat(adjustment)).toFixed(2)
      $('#garment_' + name).val(calculations)
      $('#allowance_' + name).val(new_allowance - 0.25)
    else
      $.calculations.default(obj, name, fit_name, new_allowance)

  shirt_shirt_length_front_tuck_in: (obj, name, fit_name, allowance = false) ->
    $.calculations.default(obj, name, fit_name, allowance)
    $('#measurement_shirt_shirt_length_back_tuck_in,
       #measurement_shirt_shirt_length_front_tuck_out,
       #measurement_shirt_shirt_length_back_tuck_out').each ->
      $(this).val(obj.val())
      $.calculations.default($(this), ($(this).attr('id')).replace(/measurement_/, ''), fit_name)
    $.calculate_percentage(obj, name, $.warningSiblings[name])

  #JACKET
  jacket_neck: (obj, name, fit_name, allowance = false) ->
    chest = $('#value_body_shape_postures_prominent_chest').find('option:selected').text().toLowerCase()

    if chest == 'very prominent chest'
      allowance ||= if parseFloat(obj.val()) < 16 then -0.5 else -0.75
      adjustment = $('#adjustment_' + name).val() || 0.0
      calculations = (parseFloat(obj.val()) + parseFloat(allowance) + parseFloat(adjustment)).toFixed(2)
      $('#garment_' + name).val(calculations)
      $('#allowance_' + name).val(allowance)
    else
      $.calculations.default(obj, name, fit_name, allowance)

  jacket_chest: (obj, name, fit_name, allowance = false) ->
    chest = $('#value_body_shape_postures_prominent_chest').find('option:selected').text().toLowerCase()
    body_type = $('#value_body_shape_postures_body_type').find('option:selected').text().toLowerCase()
    fit = get_fit(fit_name)

    if chest == 'very prominent chest' and fit != 'singapore-slim'
      allowance ||= parseFloat($('#allowance_' + name).data(fit)) - 0.25
    else if body_type == 'average with belly' || body_type == 'full figure'
      allowance ||= parseFloat($('#allowance_' + name).data(fit)) + 0.25
    else
      allowance ||= $('#allowance_' + name).data(fit)

    adjustment = $('#adjustment_' + name).val() || 0.0
    calculations = (parseFloat(obj.val()) + parseFloat(allowance) + parseFloat(adjustment)).toFixed(2)
    $('#garment_' + name).val(calculations)
    $('#allowance_' + name).val(allowance)

    $.calculate_percentage(obj, name, 'jacket_waist_belly_button')

    $.calculations['jacket_waist_belly_button']($('#measurement_jacket_waist_belly_button'), 'jacket_waist_belly_button', 'jacket_fit')
    # $.validations['jacket_waist_belly_button']($('#garment_jacket_waist_belly_button'))

    # $.validations['jacket_hip']($('#garment_jacket_hip'))
    $.calculations['jacket_hip']($('#measurement_jacket_hip'), 'jacket_hip', 'jacket_fit')

  jacket_waist_belly_button: (obj, name, fit_name, allowance = false) ->
    $.calculations.default(obj, name, fit_name, allowance)
    $.calculate_percentage(obj, name, 'jacket_chest')
    # $.validations['jacket_chest']($('#garment_jacket_chest'))
    $.calculations['jacket_hip']($('#measurement_jacket_hip'), 'jacket_hip', 'jacket_fit')
    # $.calculations['jacket_chest']($('#measurement_jacket_chest'), 'jacket_chest', 'jacket_fit')

  jacket_hip: (obj, name, fit_name, allowance = false) ->
    fit = get_fit(fit_name)

    allowance ||= $('#allowance_' + name).data(fit)
    adjustment = $('#adjustment_' + name).val() || 0.0
    calculations = (parseFloat(obj.val()) + parseFloat(allowance) + parseFloat(adjustment)).toFixed(2)
    chest_garment = parseFloat($('#garment_jacket_chest').val())

    if calculations < $('#garment_jacket_waist_belly_button').val()
      $('#garment_' + name).val($('#garment_jacket_waist_belly_button').val())
    else if (calculations / chest_garment) < 0.95
      calculations = parseFloat(calculations) + 0.5
      $('#garment_' + name).val(calculations)
    else if (calculations - chest_garment) >= 0.5
      calculations = parseFloat(calculations) - 0.5
      $('#garment_' + name).val(calculations)
    else
      $('#garment_' + name).val(calculations)

    $('#allowance_' + name).val(parseFloat($('#garment_' + name).val()) - parseFloat(obj.val()) - parseFloat(adjustment))

    $.calculate_percentage(obj, name, $.warningSiblings[name])
    # $.validations[name]($('#garment_' + name))

  jacket_wrist_cuff: (obj, name, fit_name, allowance = false) ->
    fit = get_fit(fit_name)

    garment_biceps = parseFloat($('#garment_jacket_biceps').val())
    wrist_cuff_measurement = parseFloat($('#measurement_' + name).val())
    adjustment = parseFloat($('#adjustment_' + name).val()) || 0.0
    allowance ||= $('#allowance_' + name).data(fit)

    switch
      when garment_biceps >= 17 && (wrist_cuff_measurement + parseFloat(allowance)) < 12
        $('#garment_' + name).val(12 + adjustment)
        $('#allowance_' + name).val(parseFloat($('#garment_' + name).val()) - parseFloat(obj.val()).toFixed(2))
        break
      when garment_biceps >= 16 && (wrist_cuff_measurement + parseFloat(allowance)) < 11.75
        $('#garment_' + name).val(11.75 + adjustment)
        $('#allowance_' + name).val(parseFloat($('#garment_' + name).val()) - parseFloat(obj.val()).toFixed(2))
        break
      when garment_biceps >= 15 && (wrist_cuff_measurement + parseFloat(allowance)) < 11.5
        $('#garment_' + name).val(11.5 + adjustment)
        $('#allowance_' + name).val(parseFloat($('#garment_' + name).val()) - parseFloat(obj.val()).toFixed(2))
        break
      when garment_biceps >= 14.5 && (wrist_cuff_measurement + parseFloat(allowance)) < 11.25
        $('#garment_' + name).val(11.25 + adjustment)
        $('#allowance_' + name).val(parseFloat($('#garment_' + name).val()) - parseFloat(obj.val()).toFixed(2))
        break
      when garment_biceps >= 14.25 && (wrist_cuff_measurement + parseFloat(allowance)) < 11
        $('#garment_' + name).val(11 + adjustment)
        $('#allowance_' + name).val(parseFloat($('#garment_' + name).val()) - parseFloat(obj.val()).toFixed(2))
        break
      when garment_biceps >= 13.25 && (wrist_cuff_measurement + parseFloat(allowance)) < 10.75
        $('#garment_' + name).val(10.75 + adjustment)
        $('#allowance_' + name).val(parseFloat($('#garment_' + name).val()) - parseFloat(obj.val()).toFixed(2))
        break
      when garment_biceps >= 13.24 && (wrist_cuff_measurement + parseFloat(allowance)) < 10.5
        $('#garment_' + name).val(10.5 + adjustment)
        $('#allowance_' + name).val(parseFloat($('#garment_' + name).val()) - parseFloat(obj.val()).toFixed(2))
        break
      else
        $.calculations.default(obj, name, fit_name, allowance)

  jacket_biceps: (obj, name, fit_name, allowance = false) ->
    fit = get_fit(fit_name)

    adjustment = $('#adjustment_' + name).val() || 0.0
    allowance ||= $('#allowance_' + name).data(fit)

    if parseFloat(obj.val()) > 14.5
      unless parseFloat(allowance) > 2.4
        allowance = 2.5

    calculations = (parseFloat(obj.val()) + parseFloat(allowance) + parseFloat(adjustment)).toFixed(2)
    $('#garment_' + name).val(calculations)
    $('#allowance_' + name).val(allowance)
    $.calculations['jacket_wrist_cuff']($('#measurement_jacket_wrist_cuff'), 'jacket_wrist_cuff', 'jacket_fit')

  jacket_jacket_length_front: (obj, name, fit_name, allowance = false) ->
    $.calculations.default(obj, name, fit_name, allowance)

    $.calculations.jacket_button_position_1_buttons($('#measurement_jacket_button_position_1_buttons'), 'jacket_button_position_1_buttons', fit_name)
    $.calculations.jacket_button_position_2_buttons($('#measurement_jacket_button_position_2_buttons'), 'jacket_button_position_2_buttons', fit_name)

    $('#measurement_jacket_button_position_2_buttons').attr('readonly', true)
    $('#measurement_jacket_button_position_1_buttons').attr('readonly', true)

    $.calculate_percentage(obj, name, $.warningSiblings[name])

  jacket_button_position_1_buttons: (obj, name, fit_name, allowance = false, alteration = false) ->
    fit = get_fit(fit_name)

    if alteration
      front_val = parseFloat($('#post_alter_garment_jacket_jacket_length_front').val())
      button_1_allowance = 0.59
    else
      front_val = parseFloat($('#garment_jacket_jacket_length_front').val())
      button_1_allowance = parseFloat($('#allowance_jacket_button_position_1_buttons').data(fit))

    button_1_adjustment = parseFloat($('#adjustment_jacket_button_position_1_buttons').val()) || 0.0
    button_1_val = (front_val * button_1_allowance + button_1_adjustment).toFixed(2)

    if alteration
      $('#post_alter_garment_jacket_button_position_1_buttons').val(button_1_val)
    else
      $('#garment_jacket_button_position_1_buttons').val(button_1_val)

    $('#allowance_jacket_button_position_1_buttons').val(button_1_allowance)
    $('#measurement_jacket_button_position_1_buttons').attr('readonly', true)


  jacket_button_position_2_buttons: (obj, name, fit_name, allowance = false, alteration = false) ->
    fit = get_fit(fit_name)
    body_type = $('#value_body_shape_postures_body_type').find('option:selected').text().toLowerCase()

    if alteration
      front_val = parseFloat($('#post_alter_garment_jacket_jacket_length_front').val())
      button_2_allowance = 0.57
    else
      front_val = parseFloat($('#garment_jacket_jacket_length_front').val())
      button_2_allowance = parseFloat($('#allowance_jacket_button_position_2_buttons').data(fit))

    button_2_adjustment = parseFloat($('#adjustment_jacket_button_position_2_buttons').val()) || 0.0

    if body_type == 'average with belly' || body_type == 'full figure'
      button_2_allowance = 0.59

    button_2_val = (front_val * button_2_allowance + button_2_adjustment).toFixed(2)

    if alteration
      $('#post_alter_garment_jacket_button_position_2_buttons').val(button_2_val)
    else
      $('#garment_jacket_button_position_2_buttons').val(button_2_val)

    $('#allowance_jacket_button_position_2_buttons').val(button_2_allowance)
    $('#measurement_jacket_button_position_2_buttons').attr('readonly', true)

  #PANTS
  pants_hip_pants_no_pleats: (obj, name, fit_name, allowance = false) ->
    $.calculations.default(obj, name, fit_name, allowance)
    $('#measurement_pants_hip_pants_with_pleats').val(obj.val())
    $.calculations.default($('#measurement_pants_hip_pants_with_pleats'), 'pants_hip_pants_with_pleats', 'pants_fit')
    $.calculations['pants_thigh']($('#measurement_pants_thigh'), 'pants_thigh', 'pants_fit')

  pants_rise: (obj, name, fit_name, allowance = false) ->
    $.calculations.default(obj, name, fit_name, allowance)

  pants_thigh: (obj, name, fit_name, allowance = false) ->
    $.calculations.default(obj, name, fit_name, allowance)

    # $.validations[name]($('#garment_' + name))
    $.methods.calculateChecks(parseFloat($('#garment_' + name).val()).toFixed(2), 'garment_pants_thigh')
    $.methods.calculateAbsChecks(parseFloat($('#garment_' + name).val()).toFixed(2), 'garment_pants_thigh')

    $.calculate_percentage(obj, name, 'pants_hip_pants_no_pleats')

    $.calculations['pants_knee']($('#measurement_pants_knee'), 'pants_knee', 'pants_fit')
    $.calculations['pants_pant_cuff']($('#measurement_pants_pant_cuff'), 'pants_pant_cuff', 'pants_fit')

  pants_knee: (obj, name, fit_name, allowance = false) ->
    thigh = parseFloat($('#garment_pants_thigh').val())
    cuff = parseFloat($('#garment_pants_pant_cuff').val())
    adjustment = $('#adjustment_' + name).val() || 0.0

    calculations = (thigh - ((thigh - cuff) / 3 * 2.05) + parseFloat(adjustment)).toFixed(2)
    $('#garment_' + name).val(calculations)
    $('#allowance_' + name).val((parseFloat($('#garment_' + name).val()) - parseFloat($('#measurement_' + name).val())).toFixed(2))

    $.calculate_percentage(obj, name, 'pants_thigh')
    $.validations[name]($('#garment_' + name))
    $.validations['pants_pant_cuff']($('#garment_pants_pant_cuff'))

  pants_calf: (obj, name, fit_name, allowance = false) ->
    $.calculations.default(obj, name, fit_name, allowance)
    $.validations['pants_pant_cuff']($('#garment_pants_pant_cuff'))

  pants_pant_cuff: (obj, name, fit_name, allowance = false) ->
    $.calculations.default(obj, name, fit_name, allowance)
    $.calculations['pants_knee']($('#measurement_pants_knee'), 'pants_knee', 'pants_fit')
    $.calculate_percentage(obj, name, 'pants_knee')

  pants_pant_length_outseam: (obj, name, fit_name, allowance = false) ->
    $.calculations.default(obj, name, fit_name, allowance)

    $.calculate_percentage(obj, name, $.warningSiblings[name])

  pants_pant_length_outseam_left_leg: (obj, name, fit_name, allowance = false) ->
    $.calculations.default(obj, name, fit_name, allowance)

    $.calculate_percentage(obj, name, $.warningSiblings[name])

  pants_pant_length_outseam_right_leg: (obj, name, fit_name, allowance = false) ->
    $.calculations.default(obj, name, fit_name, allowance)

    $.calculate_percentage(obj, name, $.warningSiblings[name])

  #CHINOS
  chinos_hip_pants_no_pleats: (obj, name, fit_name, allowance = false) ->
    $.calculations.default(obj, name, fit_name, allowance)
    $('#measurement_chinos_hip_pants_with_pleats').val(obj.val())
    $.calculations.default($('#measurement_chinos_hip_pants_with_pleats'), 'chinos_hip_pants_with_pleats', 'chinos_fit')

    $.calculations['chinos_thigh']($('#measurement_chinos_thigh'), 'chinos_thigh', 'chinos_fit')

  chinos_thigh: (obj, name, fit_name, allowance = false) ->
    $.calculations.default(obj, name, fit_name, allowance)

    # $.validations[name]($('#garment_' + name))
    $.methods.calculateChecks(parseFloat($('#garment_' + name).val()).toFixed(2), 'garment_chinos_thigh')
    $.methods.calculateAbsChecks(parseFloat($('#garment_' + name).val()).toFixed(2), 'garment_chinos_thigh')

    $.calculate_percentage(obj, name, 'chinos_hip_pants_no_pleats')

    $.calculations['chinos_knee']($('#measurement_chinos_knee'), 'chinos_knee', 'chinos_fit')
    $.calculations['chinos_pant_cuff']($('#measurement_chinos_pant_cuff'), 'chinos_pant_cuff', 'chinos_fit')

  chinos_knee: (obj, name, fit_name, allowance = false) ->
    thigh = parseFloat($('#garment_chinos_thigh').val())
    cuff = parseFloat($('#garment_chinos_pant_cuff').val())
    adjustment = $('#adjustment_' + name).val() || 0.0

    calculations = (thigh - ((thigh - cuff) / 3 * 2.05) + parseFloat(adjustment)).toFixed(2)
    $('#garment_' + name).val(calculations)
    $('#allowance_' + name).val((parseFloat($('#garment_' + name).val()) - parseFloat($('#measurement_' + name).val())).toFixed(2))

    $.calculate_percentage(obj, name, 'chinos_thigh')
    $.validations[name]($('#garment_' + name))
    $.validations['chinos_pant_cuff']($('#garment_chinos_pant_cuff'))

  chinos_calf: (obj, name, fit_name, allowance = false) ->
    $.calculations.default(obj, name, fit_name, allowance)
    $.validations['chinos_pant_cuff']($('#garment_chinos_pant_cuff'))

  chinos_pant_cuff: (obj, name, fit_name, allowance = false) ->
    $.calculations.default(obj, name, fit_name, allowance)
    $.calculations['chinos_knee']($('#measurement_chinos_knee'), 'chinos_knee', 'chinos_fit')
    $.calculate_percentage(obj, name, 'chinos_knee')

  chinos_pant_length_outseam: (obj, name, fit_name, allowance = false) ->
    $.calculations.default(obj, name, fit_name, allowance)

    $.calculate_percentage(obj, name, $.warningSiblings[name])

  chinos_pant_length_outseam_left_leg: (obj, name, fit_name, allowance = false) ->
    $.calculations.default(obj, name, fit_name, allowance)

    $.calculate_percentage(obj, name, $.warningSiblings[name])

  chinos_pant_length_outseam_right_leg: (obj, name, fit_name, allowance = false) ->
    $.calculations.default(obj, name, fit_name, allowance)

    $.calculate_percentage(obj, name, $.warningSiblings[name])

  #WAISTCOAT

  #OVERCOAT
  overcoat_hip: (obj, name, fit_name, allowance = false) ->
    fit = get_fit(fit_name)
    allowance ||= $('#allowance_' + name).data(fit)
    adjustment = $('#adjustment_' + name).val() || 0.0
    calculations = (parseFloat(obj.val()) + parseFloat(allowance) + parseFloat(adjustment)).toFixed(2)
    chest_garment = parseFloat($('#garment_overcoat_chest').val())

    if calculations < $('#garment_overcoat_waist').val()
      $('#garment_' + name).val($('#garment_overcoat_waist').val())
    else if calculations / chest_garment < 0.95
      calculations = parseFloat(calculations) + 0.5
      $('#garment_' + name).val(calculations)
    else
      $('#garment_' + name).val(calculations)

    $('#allowance_' + name).val(parseFloat($('#garment_' + name).val()) - parseFloat(obj.val()) - parseFloat(adjustment))
