$.fitting_garments =
  toggle_columns: (checkbox) ->
    category_id = checkbox.closest('.row').find('.category-checkboxes').val()
    category_table = $(".category-table[data-id='#{category_id}']")
    if checkbox.is(':checked')
      category_table.find('.fitting_garment, .changes, .fitting-garment-td').removeClass('hidden')
      category_table.find('.allowances, .final-garments').attr('readonly', 'readonly')
    else
      category_table.find('.fitting_garment, .changes, .fitting-garment-td, .change-fitting-garment-link').addClass('hidden')
      category_table.find('.fitting-garment-selector, .fitting-garment-changes, .fitting-garment-value').val('')
      category_table.find('.allowances, .final-garments, .measurements-input').attr('readonly', false)

  calculate_change: ($change_input) ->
    final_garment = $change_input.closest('tr').find('.final-garments')
    fitting_garment_value = $change_input.closest('tr').find('.fitting-garment-value')
    new_final_garment_value = (parseFloat(fitting_garment_value.val() || 0.0) + parseFloat($change_input.val() || 0.0)).toFixed(2)

    if final_garment.attr('id') == 'garment_pants_knee' && $change_input.val() != ''
      final_garment.val(new_final_garment_value)
      $.final_garment_calculations.calculate(final_garment)
    else if final_garment.attr('id') == 'garment_pants_knee' && $change_input.val() == ''
      $.calculations['pants_knee']($('#measurement_pants_knee'), 'pants_knee', 'pants_fit')
      $.custom_validations.validate_with_dependencies(
        $('.measurement-form').serializeFormJSON(),
        $('#fit-form').serializeFormJSON(),
        $('#garment_pants_knee').closest('tr').attr('data-category-param-id')
      )
    else if final_garment.attr('id') == 'garment_chinos_knee' && $change_input.val() != ''
      final_garment.val(new_final_garment_value)
      $.final_garment_calculations.calculate(final_garment)
    else if final_garment.attr('id') == 'garment_chinos_knee' && $change_input.val() == ''
      $.calculations['chinos_knee']($('#measurement_chinos_knee'), 'chinos_knee', 'chinos_fit')
      $.custom_validations.validate_with_dependencies(
        $('.measurement-form').serializeFormJSON(),
        $('#fit-form').serializeFormJSON(),
        $('#garment_chinos_knee').closest('tr').attr('data-category-param-id')
      )
    else
      final_garment.val(new_final_garment_value)
      $.final_garment_calculations.calculate(final_garment)

  changes_siblings:
    'shirt_shirt_sleeve_length_right_sleeve': 'shirt_shirt_sleeve_length_left_sleeve',
    'shirt_shirt_sleeve_length_left_sleeve': 'shirt_shirt_sleeve_length_right_sleeve',
    'jacket_jacket_sleeve_length_left_sleeve': 'jacket_jacket_sleeve_length_right_sleeve',
    'jacket_jacket_sleeve_length_right_sleeve': 'jacket_jacket_sleeve_length_left_sleeve',
    'pants_pant_length_outseam_left_leg': 'pants_pant_length_outseam_right_leg',
    'pants_pant_length_outseam_right_leg': 'pants_pant_length_outseam_left_leg',
    'chinos_pant_length_outseam_left_leg': 'chinos_pant_length_outseam_right_leg',
    'chinos_pant_length_outseam_right_leg': 'chinos_pant_length_outseam_left_leg',
    'overcoat_overcoat_sleeve_length_right_sleeve': 'overcoat_overcoat_sleeve_length_left_sleeve',
    'overcoat_overcoat_sleeve_length_left_sleeve': 'overcoat_overcoat_sleeve_length_right_sleeve',

$(document).on 'ready turbolinks:load', ->
  $('body').on 'change', '.fitting-garment-selector', ->
    $(this).closest('table').find('.change-fitting-garment-link').removeClass('hidden')
    id = $(this).val()
    $.ajax
      type: 'GET'
      url: "/fitting_garments/#{id}"
      dataType: 'script'

  $('body').on 'change, blur', '.fitting-garment-changes', ->
    return if $(this).attr('readonly') || $(this).attr('disabled')

    name = $(this).attr('id')
    name = name.replace(/fitting_garment_changes_/, '')
    sibling_name = $.fitting_garments.changes_siblings[name]

    $.fitting_garments.calculate_change($(this))

    if sibling_name
      $sibling_change = $("#fitting_garment_changes_#{sibling_name}")
      $sibling_change.val($(this).val())

      $.prefill.clearPrefillMessage($(this))
      $.prefill.clearPrefillMessage($sibling_change)
      $sibling_change.closest('td').addClass('info-td-msg')
      $sibling_change.closest('td').append("<span class='info-text-msg uppercase'><b>Autofill: </b>#{name.split('_').join(' ')}</span>")

      $.fitting_garments.calculate_change($($sibling_change))


  $('body').on 'change', '.fitting-garment-check', ->
    $.fitting_garments.toggle_columns($(this))

  $('body').on 'change', '.fitting-garment-single-selector', ->
    tr = $(this).closest('tr')
    tr.find('.fitting-garment-measurement-id').val($(this).val())
    tr.find('td.fitting-selector').addClass('alert-td-msg')
    if tr.find('.alert-text-msg').length
      tr.find('.alert-text-msg').replaceWith("<span class='alert-text-msg uppercase'><br><b>Fitting Garment: </b>#{$(this).find('option:selected').text()}</span>")
    else
      tr.find('td.fitting-selector').append("<span class='alert-text-msg uppercase'><br><b>Fitting Garment: </b>#{$(this).find('option:selected').text()}</span>")

    id = $(this).val()
    category_param_id = tr.attr('data-category-param-id')

    $.ajax
      type: 'GET'
      url: "/fitting_garments/#{id}"
      dataType: 'script'
      data:
        category_param_id: category_param_id
