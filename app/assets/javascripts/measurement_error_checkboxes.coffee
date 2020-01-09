$.measurement_error_checkboxes =
  set_checkbox: (tr) ->
    category_status = tr.closest('.category-table').attr('data-status')
    unless $('.submit-form').attr('data-review') == 'true' || category_status == 'submitted' || category_status == 'confirmed'
      container = tr.find('.issues')
      unless container.find('.confirm-errors-container').not('.hidden').length
        container.find('.confirm-errors-container').removeClass('hidden')
        $('#save-to-be-submitted-button').hide()
        unless container.find('.confirm-errors-checkbox:checked').length
          $('#save-to-be-reviewed-button').attr('disabled', 'disabled')
      if $(".issue[data-fixed='true']").length != $(".issue").length
        $('#save-to-be-reviewed-button').attr('disabled', 'disabled')
    if $('.submit-form').attr('data-review') == 'true'
      if $('.error-message').length > 0
        $('#save-to-be-submitted-button').hide()
      else
        $('#save-to-be-submitted-button').show()

  unset_checkbox: (tr) ->
    category_status = tr.closest('.category-table').attr('data-status')
    unless $('.submit-form').attr('data-review') == 'true' || category_status == 'submitted' || category_status == 'confirmed'
      if tr.find('.error-message').length == 0
        tr.find('.issues').find('.confirm-errors-container').addClass('hidden')
      if $('.confirm-errors-container').not('.hidden').length == 0 && $(".issue[data-fixed='true']").length == $(".issue").length
        $('#save-to-be-reviewed-button').removeAttr('disabled')
        $('#save-to-be-submitted-button').show()
      if $('.confirm-errors-container').not('.hidden').find('.confirm-errors-checkbox:checked').length == $('.confirm-errors-container').not('.hidden').length && $(".issue[data-fixed='true']").length == $(".issue").length
        $('#save-to-be-reviewed-button').removeAttr('disabled')
    if $('.submit-form').attr('data-review') == 'true'
      if $('.error-message').length > 0
        $('#save-to-be-submitted-button').hide()
      else
        $('#save-to-be-submitted-button').show()

$(document).ready ->
  $('body').on 'change', '.confirm-errors-checkbox', (e) ->
    unless $('.submit-form').attr('data-review') == 'true'
      if $('.confirm-errors-container').not('.hidden').find('.confirm-errors-checkbox:checked').length == $('.confirm-errors-container').not('.hidden').length
        $('#save-to-be-reviewed-button').removeAttr('disabled')
      else
        $('#save-to-be-reviewed-button').attr('disabled', 'disabled')
