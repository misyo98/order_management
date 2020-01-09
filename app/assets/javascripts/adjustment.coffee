$(document).ready ->
  $('body').on 'change', '.calculatable-adjustments', () ->
    name = $(this).attr('id').replace(/adjustment_/, '')
    measurement = $('#measurement_' + name)
    garment = $('#garment_' + name)
    fit_name = name.replace(/_.*/, '_fit')

    adjustment_val = (parseFloat($(this).val()) - parseFloat($(this).attr('data-default-adjustment'))).toFixed(2)
    garment_val = garment.attr('data-init-value')
    new_val = (parseFloat(garment_val) + parseFloat(adjustment_val)).toFixed(2)
    garment.val(new_val)

    pants_knee_categories = ['pants_knee', 'pants_thigh', 'pants_pant_cuff']
    chinos_knee_categories = ['chinos_knee', 'chinos_thigh', 'chinos_pant_cuff']

    if name == 'height_height_cm'
      to_inches = Math.round(new_val / 2.54)
      $('#garment_height_height_inches').val(to_inches)
      $('#adjustment_height_height_inches').val(parseFloat(to_inches) - parseFloat($('#measurement_height_height_inches').val()))
      $.methods.calculateChecks((parseFloat(to_inches)), 'garment_height_height_inches')
    else if name == 'jacket_jacket_length_front'
      $.calculations.jacket_button_position_1_buttons($('#measurement_jacket_button_position_1_buttons'), 'jacket_button_position_1_buttons', 'jacket_fit')
      $.calculations.jacket_button_position_2_buttons($('#measurement_jacket_button_position_2_buttons'), 'jacket_button_position_2_buttons', 'jacket_fit')
    else if pants_knee_categories.includes(name)
      $.calculations.pants_knee($('#measurement_pants_knee'), 'pants_knee', 'pants_fit')
    else if chinos_knee_categories.includes(name)
      $.calculations.chinos_knee($('#measurement_chinos_knee'), 'chinos_knee', 'chinos_fit')

    if name in Object.keys($.warningSiblings)
      sibling = $.warningSiblings[name]
      percentage = Math.round((parseFloat(garment.val()) / parseFloat($('#garment_'+ sibling).val()) * 100))
      garment.closest('tr').find('.percent').html(percentage + '%')

    if typeof $.validations[name] == 'function'
      $.validations[name]($('#garment_' + name))


    $.custom_validations.validate_with_dependencies(
      $('.measurement-form').serializeFormJSON(),
      $('#fit-form').serializeFormJSON(),
      measurement.closest('tr').attr('data-category-param-id')
    )

  $('body').on 'blur', '.calculatable-adjustments', () ->
    name = $(this).attr('id').replace(/adjustment_/, '')
    measurement = $('#measurement_' + name)

    $.custom_validations.validate_with_dependencies(
      $('.measurement-form').serializeFormJSON(),
      $('#fit-form').serializeFormJSON(),
      measurement.closest('tr').attr('data-category-param-id')
    )

  $('body').on 'change', '.adjustment-value', () ->
    name = $(this).attr('id').replace(/adjustment_/, '')

    $.custom_validations.validate_with_dependencies(
      $('.measurement-form').serializeFormJSON(),
      $('#fit-form').serializeFormJSON(),
      $("##{name}").closest('tr').attr('data-category-param-id')
    )

