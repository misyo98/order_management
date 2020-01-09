invert = (obj) ->
  new_obj = {}
  for prop of obj
    if obj.hasOwnProperty(prop)
      new_obj[obj[prop]] = prop
  new_obj

$(document).ready ->
  $('body').on 'change', '#save_without_changes', () ->
    if $(this).is(':checked')
      swal {
        title: 'Warning! Save without changes selected.'
        text: 'These changes will NOT affect final garment measurements, are you sure?'
        type: 'warning'
        showCancelButton: true
        confirmButtonClass: 'btn-success'
        confirmButtonText: 'Yes'
        cancelButtonText: 'No'
        closeOnConfirm: yes
        closeOnCancel: yes
      }, (isConfirm) ->
        unless isConfirm
          document.getElementById('save_without_changes').checked = null

  hide_extra_fields = $('#without_extra_fields').val() == 'true'
  if hide_extra_fields
    $('#manufacturer').val('Adjustment');

  BODY_SHAPE_CATEGORY_ID = '8'
  HEIGHT_CATEGORY_ID = '1'

  $('body').on 'change', '.alteration', () ->
    return true if $(this).attr('readonly') || $(this).attr('disabled')
    name = $(this).attr('id').replace(/alteration_/, '')
    post_alter_garment = $(this).closest('tr').find('.post-alter-garment')
    post_alter_default_val = parseFloat(post_alter_garment.attr('data-default-value'))
    alteration = parseFloat($(this).val())
    alteration ||= 0

    unless isNaN(alteration)
      post_alter_garment.val((post_alter_default_val + alteration).toFixed(2))
      sibling = $.warningSiblings[name]

      percentage = (parseFloat($('#post_alter_garment_' + name).val()) / parseFloat($('#post_alter_garment_'+ sibling).val()) * 100).toFixed(1)
      $(this).closest('tr').find('.percent').html(percentage + '%')

      if name != 'height_height_cm' && invert($.warningSiblings)[name]
        inverted_name = invert($.warningSiblings)[name]
        percentage = (parseFloat($('#post_alter_garment_' + inverted_name).val()) / parseFloat($('#post_alter_garment_'+ name).val()) * 100).toFixed(1)
        $('#garment_' + inverted_name).closest('tr').find('.percent').html(percentage + '%')

      if $(this).attr('id') == 'alteration_height_height_cm'
        inches_val = $('#post_later_garment_height_height_inches')
        inches_val.val(Math.round(parseFloat(post_alter_garment.val()) / 2.54))
        inches_final = $('#garment_height_height_inches')
        inches_alteration = Math.round(parseFloat(inches_val.val()) - parseFloat(inches_final.val()))
        $('#alteration_height_height_inches').val(inches_alteration)

      if $(this).attr('id') == 'alteration_jacket_jacket_length_front'
        $.calculations['jacket_button_position_1_buttons']($('#garment_jacket_button_position_1_buttons'), 'jacket_button_position_1_buttons', 'jacket_fit', false, true)
        $.calculations['jacket_button_position_2_buttons']($('#garment_jacket_button_position_2_buttons'), 'jacket_button_position_2_buttons', 'jacket_fit', false, true)

      if typeof $.validations[name] == 'function'
        $.validations[name]($('#post_alter_garment_' + name), 'post_alter_garment_')

  #function for validation PES number before submit
  $('body').on 'click', '.measurement_alteration_submit', (e) ->
    checked_categories = {}
    $('.categories-checkboxes').find('input:checked').each ->
      checked_categories[$(this).attr('id')] = $(this).attr('name')
    delete checked_categories[HEIGHT_CATEGORY_ID]

    checked_categories_without_alterations = $.extend({}, checked_categories)
    delete checked_categories_without_alterations[BODY_SHAPE_CATEGORY_ID]

    $.each checked_categories, (category_id, category_name) ->
      $("#measurement-table-#{category_id}").find('.alteration-value').each ->
        if ($(this).val().length && parseFloat($(this).val()) > 0 || ($(this).val() < 0))
          delete checked_categories_without_alterations[category_id]

    $('#selected-categories-field').val(Object.values(checked_categories).join(', '))

    submit_button = $(this)
    e.preventDefault()
    # set requested action based on which button - aleration or remake was clicked
    $('#requested_action').val(submit_button.val())

    violate_validations_hash = {}
    $('.error-message').each ->
      param_category = $(this).closest('tr').find('.category-name-field').find('span').text()
      param_name = $(this).closest('tr').find('.param-name-field').text().replace(/\s/g, '');
      error_text = $(this).text()
      present_value = $(this).closest('tr').find('.alteration').val()
      return if present_value == '' || present_value == undefined
      return unless Object.values(checked_categories).includes(param_category) || jQuery.isEmptyObject(checked_categories)

      violate_validations_hash[error_text] = "#{param_category} - #{param_name}"
    $('#violate_validations_hash').val(JSON.stringify(violate_validations_hash))

    validation_fields = ['#manufacturer','#alteration_summary_urgent','#alteration_summary_requested_completion',
      '#alteration_summary_alteration_request_taken','#alteration_summary_delivery_method',
      '#alteration_summary_non_altered_items','#alteration_summary_remaining_items']
    error = false
    unless hide_extra_fields
      $.each validation_fields, (index, name) ->
        if !$(name).val()
          $(name).addClass('error_field')
          $(name).attr('placeholder', 'This field is required')
          $(name).goTo()
          error = true
          return false
        else if $(name).hasClass('error_field')
          $(name).removeClass('error_field')

    unless error
      swal {
        title: 'Confirm Measurements'
        text: 'Would you like to confirm these measurement profiles and trigger all remaining items?'
        type: 'info'
        showCancelButton: true
        confirmButtonClass: 'btn-success'
        confirmButtonText: 'Yes'
        cancelButtonText: 'No'
        closeOnConfirm: false
        closeOnCancel: false
      }, (isConfirm) ->
        if isConfirm
          $.each checked_categories, (category_id, category_name) ->
            category_name_parameterized =
              category_name.trim().toLowerCase().replace(/[^a-zA-Z0-9 -]/, '').replace('  ', ' ').replace(/\s/g, '-')

            $(".#{category_name_parameterized}-category-status").val('confirmed') if $(".#{category_name_parameterized}-category-status").val('submitted')
        else
          $.each checked_categories, (category_id, category_name) ->
            category_name_parameterized =
              category_name.trim().toLowerCase().replace(/[^a-zA-Z0-9 -]/, '').replace('  ', ' ').replace(/\s/g, '-')

            $(".#{category_name_parameterized}-category-status").val('submitted') if $(".#{category_name_parameterized}-category-status").val('confirmed')

        unless $.isEmptyObject(checked_categories_without_alterations)
          swal {
            title: 'Empty Measurements'
            text: "#{Object.values(checked_categories_without_alterations).join(', ')} don't seem to have alterations, are you sure you want to include it? Otherwise uncheck"
            type: 'warning'
            showCancelButton: true
            confirmButtonClass: 'btn-success'
            confirmButtonText: 'Yes'
            cancelButtonText: 'No'
            closeOnConfirm: true
            closeOnCancel: true
          }, (isConfirm) ->
            if isConfirm
              $('button.confirm').prop('disabled', true)
              $('button.cancel').prop('disabled', true)
              submit_button.submit()

              $("#fakeloader").fakeLoader
                spinner: 'spinner1'
                timeToHide: 65000
        else
          $('button.confirm').prop('disabled', true)
          $('button.cancel').prop('disabled', true)
          submit_button.submit()

          $("#fakeloader").fakeLoader
            spinner: 'spinner1'
            timeToHide: 65000

  #function for initializing checks on alteration form
  if $('#alteration-form').length
    $.methods.maybeUpdateDefaultChecks()
    $.methods.setDefaultAbsChecks()
    $.methods.setAlterPercentageWarnings()
    $.methods.setRealPercentageWarnings()
    $.methods.performAlterValidations()
    $.methods.disableWaistButtonPositionField()
