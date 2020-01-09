$.custom_validations =
  validate: (serialized_form, fits_form, category_param_id) ->
    $.ajax
      type: 'POST'
      url: '/measurements/validate'
      dataType: 'json'
      data:
        form: serialized_form
        fits: fits_form
        category_param_id: category_param_id
      success: (responseData) ->
        if responseData['errors'].length
          $.custom_validations.unset_errors(category_param_id)
          $.custom_validations.set_errors(responseData['errors'], category_param_id)
        else
          $.custom_validations.unset_errors(category_param_id)
          
  validate_alteration: (serialized_form, fits_form, category_param_id) ->
    $.ajax
      type: 'POST'
      url: '/measurements/validate_alteration'
      dataType: 'json'
      data:
        form: serialized_form
        fits: fits_form
        category_param_id: category_param_id
      success: (responseData) ->
        if responseData['errors'].length
          $.custom_validations.unset_errors(category_param_id)
          $.custom_validations.set_errors(responseData['errors'], category_param_id)
        else
          $.custom_validations.unset_errors(category_param_id)

  validate_alteration: (serialized_form, fits_form, category_param_id, to_be_validated_summary_id) ->
    $.ajax
      type: 'POST'
      url: '/measurements/validate_alteration'
      dataType: 'json'
      data:
        form: serialized_form
        fits: fits_form
        category_param_id: category_param_id
        to_be_validated_summary_id: to_be_validated_summary_id
      success: (responseData) ->
        if responseData['errors'].length
          present_value = $("tr[data-category-param-id='#{category_param_id}']").find('.alteration').val()
          $.custom_validations.unset_errors(category_param_id)
          $.custom_validations.set_errors(responseData['errors'], category_param_id) unless present_value == ''
        else
          $.custom_validations.unset_errors(category_param_id)

  validate_with_dependencies: (serialized_form, fits_form, category_param_id) ->
    $.ajax
      type: 'POST'
      url: '/measurements/validate_with_dependencies'
      dataType: 'json'
      data:
        form: serialized_form
        fits: fits_form
        category_param_id: category_param_id
      success: (responseData) ->
        $.each responseData['errors'], (key, errors) ->
          if errors.length
            $.custom_validations.unset_errors(key)
            $.custom_validations.set_errors(errors, key)
          else
            $.custom_validations.unset_errors(key)

  batch_validate: (serialized_form, fits_form, category_param_ids, summary_id = null) ->
    $.ajax
      type: 'POST'
      url: '/measurements/batch_validate'
      dataType: 'json'
      data:
        form: serialized_form
        fits: fits_form
        category_param_ids: category_param_ids
        summary_id: summary_id
      success: (responseData) ->
        $.each responseData['errors'], (key, errors) ->
          if errors.length
            $.custom_validations.unset_errors(key)
            $.custom_validations.set_errors(errors, key)
          else
            $.custom_validations.unset_errors(key)


  set_errors: (errors, category_param_id) ->
    parent = $("tr[data-category-param-id='#{category_param_id}']")
    error_container = parent.find('.checks')
    error_name = "custom-errors-#{category_param_id}"

    unless error_container.find("span.#{error_name}").length >= 1
      parent.addClass('error_field') unless parent.find('.checks').hasClass('hidden') && parent.find('.alteration').length > 0
      $.each errors, (index, message) ->
        $("<span style='color: red;' class='#{error_name} error-message'><br/>#{message}</span>").appendTo(error_container)
      $.measurement_error_checkboxes.set_checkbox(parent)

  unset_errors: (category_param_id) ->
    parent = $("tr[data-category-param-id='#{category_param_id}']")
    error_container = parent.find('.checks')
    error_name = "custom-errors-#{category_param_id}"
    error_container.find("span.#{error_name}").remove()
    $.measurement_error_checkboxes.unset_checkbox(parent)
    if parent.find('.error-message').length == 0
      parent.removeClass('error_field')

$(document).ready ->
  $('body').on 'change', '.measurement-selector, .fit-selector', (e) ->
    selected_id = $(this).val()
    $(this).closest('.nested-fields').find(':input').each ->
      new_name = $(this).attr('name').replace(/(\[.*?\])/, "[#{selected_id}]")
      $(this).attr('name', new_name)

  $('body').on 'click', '#run-test-measurement-validation', (e) ->
    $('#validation-result-container').html('<div class="loader"></div>');

    category_param_id = $(this).attr('data-category-param-id')
    form = $(this).closest('form').serializeFormJSON();

    $.ajax
      type: 'POST'
      url: "/category_params/#{category_param_id}/measurement_validations/test"
      dataType: 'script'
      data: form

  $('#measurement-fields, #fit-fields').on 'cocoon:after-insert', (e, added_measurement) ->
    added_measurement.find('select').select2();
