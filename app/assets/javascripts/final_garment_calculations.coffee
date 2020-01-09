$.final_garment_calculations =
  calculate: (input) ->
    pants_knee_dependers = ['pants_thigh', 'pants_pant_cuff' ]
    chinos_knee_dependers = ['chinos_thigh', 'chinos_pant_cuff']
    jacket_hip_dependers = ['jacket_chest', 'jacket_waist_belly_button']

    name = input.attr('id')
    name = name.replace(/garment_/, '')

    garment_val = parseFloat(input.val())
    measurement_val = parseFloat($('#measurement_' + name).val())
    allowance_val = (garment_val - measurement_val).toFixed(2)

    $('#allowance_' + name).val(allowance_val)

    if name == 'jacket_jacket_length_front'
      $.calculations['jacket_button_position_1_buttons']($('#garment_jacket_button_position_1_buttons'), 'jacket_button_position_1_buttons', 'jacket_fit')
      $.calculations['jacket_button_position_2_buttons']($('#garment_jacket_button_position_2_buttons'), 'jacket_button_position_2_buttons', 'jacket_fit')

    if pants_knee_dependers.includes(name) && $('#measurement_pants_knee').closest('tr').find('.fitting-garment-changes').val() == ''
      $.calculations['pants_knee']($('#measurement_pants_knee'), 'pants_knee', 'pants_fit')
      $.custom_validations.validate_with_dependencies(
        $('.measurement-form').serializeFormJSON(),
        $('#fit-form').serializeFormJSON(),
        $('#measurement_pants_knee').closest('tr').attr('data-category-param-id')
      )
    if chinos_knee_dependers.includes(name) && $('#measurement_chinos_knee').closest('tr').find('.fitting-garment-changes').val() == ''
      $.calculations['chinos_knee']($('#measurement_chinos_knee'), 'chinos_knee', 'chinos_fit')
      $.custom_validations.validate_with_dependencies(
        $('.measurement-form').serializeFormJSON(),
        $('#fit-form').serializeFormJSON(),
        $('#measurement_chinos_knee').closest('tr').attr('data-category-param-id')
      )
    if jacket_hip_dependers.includes(name)
      unless $('#fitting_garment_value_jacket_hip').closest('td').hasClass('hidden') && parseFloat($('#fitting_garment_value_jacket_hip').val() || 0) == 0
        $.calculations['jacket_hip']($('#measurement_jacket_hip'), 'jacket_hip', 'jacket_fit')

    sibling = $.warningSiblings[name]

    $.calculate_percentage(input, name, sibling)

    if typeof $.validations[name] == 'function'
      $.validations[name](input)

    $.custom_validations.validate_with_dependencies(
      $('.measurement-form').serializeFormJSON(),
      $('#fit-form').serializeFormJSON(),
      input.closest('tr').attr('data-category-param-id')
    )


$(document).ready ->
  $('body').on 'change', '.final-garments', ->
    return if $(this).attr('readonly') || $(this).attr('disabled')

    $.final_garment_calculations.calculate($(this))

  $('body').on 'blur', '.final-garments', ->
    return if $(this).attr('readonly') || $(this).attr('disabled')

    $.custom_validations.validate_with_dependencies(
      $('.measurement-form').serializeFormJSON(),
      $('#fit-form').serializeFormJSON(),
      $(this).closest('tr').attr('data-category-param-id')
    )
