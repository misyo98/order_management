$.validations =
  #DEFAULTS
  set_error: (obj, error_name, message) ->
    td = obj.closest('tr').find('.checks')
    parent = obj.closest('tr')
    unless td.find('span.' + error_name).length == 1
      parent.addClass('error_field') unless parent.find('.checks').hasClass('hidden') && parent.find('.alteration').length > 0
      $("<span style='color: red;' class='#{error_name} error-message'><br/>#{message}</span>").appendTo(td)

  unset_error: (obj, error_name) ->
    td = obj.closest('tr').find('.checks')
    parent = obj.closest('tr')
    parent.removeClass('error_field')
    td.find("span.#{error_name}").remove()

  set_warning: (obj, warn_name, message) ->
    td = obj.closest('tr').find('.checks')
    unless td.find('span.' + warn_name).length == 1
      $("<span class='#{warn_name}'><br/>#{message}</span>").appendTo(td)

  unset_warning: (obj, warn_name) ->
    td = obj.closest('tr').find('.checks')
    td.find("span.#{warn_name}").remove()


  default_min_max: (obj, prefix) ->
    checkable_param_name = obj.closest('tr').find('.checkable').attr('data-name')
    standard = parseFloat($('#' + checkable_param_name).val())
    min = standard * parseFloat(obj.closest('tr').find('.checkable').attr('data-min'))
    max = standard * parseFloat(obj.closest('tr').find('.checkable').attr('data-max'))
    value = parseFloat(obj.val())
    pattern = new RegExp(prefix)
    error_name = (obj.attr('id')).replace(pattern, 'error_')

    if value < min || value > max
      $.validations.set_error(obj, error_name, 'Value is out of min-max range')
      $.measurement_error_checkboxes.set_checkbox(obj.closest('tr'))
    else
      $.validations.unset_error(obj, error_name)
      $.measurement_error_checkboxes.unset_checkbox(obj.closest('tr'))

  default_percentage: (obj, valid_min_value, error_name, message) ->
    if parseFloat(obj.val()) < parseFloat(valid_min_value)
      $.validations.set_warning(obj, error_name, message)
    else
      $.validations.unset_warning(obj, error_name)

  absolute_min_max: (obj, prefix) ->
    min = parseFloat(obj.closest('tr').find('.checks').attr('data-min'))
    max = parseFloat(obj.closest('tr').find('.checks').attr('data-max'))
    value = parseFloat(obj.val())
    error_name = (obj.attr('id')).replace(/garment_/, 'error_')

    if value < min || value > max
      $.validations.set_error(obj, error_name, 'Value is out of min-max range')
      $.measurement_error_checkboxes.set_checkbox(obj.closest('tr'))
    else
      $.validations.unset_error(obj, error_name)
      $.measurement_error_checkboxes.unset_checkbox(obj.closest('tr'))

  default_inches: (obj, valid_min_value, valid_max_value, error_name, message) ->
    if parseFloat(obj.val()) < parseFloat(valid_min_value) || parseFloat(obj.val()) > parseFloat(valid_max_value)
      $.validations.set_error(obj, error_name, message)
      $.measurement_error_checkboxes.set_checkbox(obj.closest('tr'))
    else
      $.validations.unset_error(obj, error_name)
      $.measurement_error_checkboxes.unset_checkbox(obj.closest('tr'))

  resolve_prefix: (custom_input) ->
    if custom_input.length > 0
      return custom_input
    else
      return 'garment_'

  #EXCEPTION HANDLERS
  resolve_shirt_jacket_sleeve_length: () ->
    s_l_sleeve = parseFloat($('#garment_shirt_shirt_sleeve_length_left_sleeve').val())
    s_r_sleeve = parseFloat($('#garment_shirt_shirt_sleeve_length_right_sleeve').val())
    s_shoulder = parseFloat($('#garment_shirt_shoulder').val())

    j_l_sleeve = parseFloat($('#garment_jacket_jacket_sleeve_length_left_sleeve').val())
    j_r_sleeve = parseFloat($('#garment_jacket_jacket_sleeve_length_right_sleeve').val())
    j_shoulder = parseFloat($('#garment_jacket_shoulder').val())

    difference = (s_l_sleeve + s_r_sleeve + s_shoulder) - (j_l_sleeve + j_r_sleeve + j_shoulder)

    if isNaN(difference)
      return
    $.validations.unset_error($('#garment_shirt_shirt_sleeve_length_left_sleeve'), 'sleeve_too_short')
    $.validations.unset_error($('#garment_jacket_jacket_sleeve_length_left_sleeve'), 'sleeve_too_short')
    $.validations.unset_error($('#garment_shirt_shirt_sleeve_length_left_sleeve'), 'sleeve_too_long')
    $.validations.unset_error($('#garment_jacket_jacket_sleeve_length_left_sleeve'), 'sleeve_too_long')

    if difference < 0.5
      $.validations.set_error(
        $('#garment_shirt_shirt_sleeve_length_left_sleeve'),
        'sleeve_too_short',
        'Shirt shoulder & sleeves not long enough for jacket'
      )
      $.validations.set_error(
        $('#garment_jacket_jacket_sleeve_length_left_sleeve'),
        'sleeve_too_short',
        'Shirt shoulder & sleeves not long enough for jacket'
      )
    else if difference > 1.5
      $.validations.set_error(
        $('#garment_shirt_shirt_sleeve_length_left_sleeve'),
        'sleeve_too_long',
        'Shirt shoulder & sleeves too long for jacket'
      )
      $.validations.set_error(
        $('#garment_jacket_jacket_sleeve_length_left_sleeve'),
        'sleeve_too_long',
        'Shirt shoulder & sleeves too long for jacket'
      )
    else
      $.validations.unset_error($('#garment_shirt_shirt_sleeve_length_left_sleeve'), 'sleeve_too_short')
      $.validations.unset_error($('#garment_jacket_jacket_sleeve_length_left_sleeve'), 'sleeve_too_short')
      $.validations.unset_error($('#garment_shirt_shirt_sleeve_length_left_sleeve'), 'sleeve_too_long')
      $.validations.unset_error($('#garment_jacket_jacket_sleeve_length_left_sleeve'), 'sleeve_too_long')

  #HANDLERS
  shirt_shoulder: (obj, prefix = 'garment_') ->
    $.validations.default_min_max(obj, prefix)

  shirt_shirt_sleeve_length: (obj, prefix = 'garment_') ->
    $.validations.default_min_max(obj, prefix)

  shirt_shirt_sleeve_length_right_sleeve: (obj, prefix = 'garment_') ->
    $.validations.default_min_max(obj, prefix)
    # $.validations.resolve_shirt_jacket_sleeve_length()

  shirt_shirt_sleeve_length_left_sleeve: (obj, prefix = 'garment_') ->
    $.validations.default_min_max(obj, prefix)
    # $.validations.resolve_shirt_jacket_sleeve_length()

  shirt_shirt_length_front_tuck_in: (obj, prefix = 'garment_') ->
    $.validations.default_min_max(obj, prefix)

  # shirt_shoulder: (obj, prefix = 'garment_') ->
  #   $.validations.resolve_shirt_jacket_sleeve_length()

  jacket_shoulder: (obj, prefix = 'garment_') ->
    $.validations.default_min_max(obj, prefix)

  jacket_jacket_sleeve_length: (obj, prefix = 'garment_') ->
    $.validations.default_min_max(obj, prefix)

  jacket_jacket_sleeve_length_right_sleeve: (obj, prefix = 'garment_') ->
    $.validations.default_min_max(obj, prefix)
    # $.validations.resolve_shirt_jacket_sleeve_length()

  jacket_jacket_sleeve_length_left_sleeve: (obj, prefix = 'garment_') ->
    $.validations.default_min_max(obj, prefix)
    # $.validations.resolve_shirt_jacket_sleeve_length()

  jacket_jacket_length_front: (obj, prefix = 'garment_') ->
    $.validations.default_min_max(obj, prefix)

  jacket_jacket_length_back: (obj, prefix = 'garment_') ->
    $.validations.default_min_max(obj, prefix)

  # jacket_shoulder: (obj, prefix = 'garment_') ->
  #   $.validations.resolve_shirt_jacket_sleeve_length()

  pants_rise: (obj, prefix = 'garment_') ->
    $.validations.absolute_min_max(obj, prefix)

  pants_knee: (obj, prefix = 'garment_') ->
    $.validations.default_min_max(obj, prefix)

  pants_pant_cuff: (obj, prefix = 'garment_') ->
    $.validations.absolute_min_max(obj, prefix)

  pants_pant_length_outseam: (obj, prefix = 'garment_') ->
    $.validations.default_min_max(obj, prefix)

  pants_pant_length_outseam_left_leg: (obj, prefix = 'garment_') ->
    $.validations.default_min_max(obj, prefix)

  pants_pant_length_outseam_right_leg: (obj, prefix = 'garment_') ->
    $.validations.default_min_max(obj, prefix)

  waistcoat_waistcoat_front_length_pointed: (obj, prefix = 'garment_') ->
    $.validations.default_min_max(obj, prefix)

  waistcoat_waistcoat_front_length_straight: (obj, prefix = 'garment_') ->
    $.validations.default_min_max(obj, prefix)

  waistcoat_waistcoat_back_length: (obj, prefix = 'garment_') ->
    $.validations.default_min_max(obj, prefix)

  overcoat_shoulder: (obj, prefix = 'garment_') ->
    $.validations.default_min_max(obj, prefix)

  overcoat_overcoat_sleeve_length: (obj, prefix = 'garment_') ->
    $.validations.default_min_max(obj, prefix)

  overcoat_overcoat_sleeve_length_left_sleeve: (obj, prefix = 'garment_') ->
    $.validations.default_min_max(obj, prefix)

  overcoat_overcoat_sleeve_length_right_sleeve: (obj, prefix = 'garment_') ->
    $.validations.default_min_max(obj, prefix)

  overcoat_overcoat_front_length: (obj, prefix = 'garment_') ->
    $.validations.default_min_max(obj, prefix)

  overcoat_overcoat_back_length: (obj, prefix = 'garment_') ->
    $.validations.default_min_max(obj, prefix)

  chinos_rise: (obj, prefix = 'garment_') ->
    $.validations.absolute_min_max(obj, prefix)

  chinos_knee: (obj, prefix = 'garment_') ->
    $.validations.default_min_max(obj, prefix)

  chinos_pant_cuff: (obj, prefix = 'garment_') ->
    $.validations.absolute_min_max(obj, prefix)

  chinos_pant_length_outseam: (obj, prefix = 'garment_') ->
    $.validations.default_min_max(obj, prefix)

  chinos_pant_length_outseam_left_leg: (obj, prefix = 'garment_') ->
    $.validations.default_min_max(obj, prefix)

  chinos_pant_length_outseam_right_leg: (obj, prefix = 'garment_') ->
    $.validations.default_min_max(obj, prefix)
