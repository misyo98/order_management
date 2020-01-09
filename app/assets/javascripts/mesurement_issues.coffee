$.measurement_issues =
  resolve_submit_buttons_state: () ->
    if $(".issue[data-fixed='true']").length != $(".issue").length
      $('#reviewed-ok-button').attr('disabled', 'disabled')
      $('#reviewed-not-ok-button').removeAttr('disabled')
      $('#save-to-be-reviewed-button').attr('disabled', 'disabled')
      $('#save-to-be-submitted-button').attr('disabled', 'disabled')
    else
      $('#reviewed-ok-button').removeAttr('disabled')
      $('#reviewed-not-ok-button').attr('disabled', 'disabled')
      $('#save-to-be-reviewed-button').removeAttr('disabled')
      $('#save-to-be-submitted-button').removeAttr('disabled')

$(document).ready ->
  # func for closing popover with issue form
  $('body').on 'click', '.popover .close' , ->
    $(this).parents('.popover').popover('hide')

  $('body').on 'click', '.issue-submit', ->
    $(this).closest('form').trigger('submit.rails')

  $('body').on 'click', '.remove-measurement-issue', ->
    $(this).closest('.issue').remove()
    $.measurement_issues.resolve_submit_buttons_state();
