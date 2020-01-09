$(document).ready ->
  $('body').on 'change', '.alteration-categories', (e) ->
    if $(this).is(":checked")
      $.ajax
        type: 'GET'
        url: $(this).attr('data-alteration-info-path')
        dataType: 'script'
        data:
          profile_id: $('input#customer').attr('data-profile-id')
          category_id: $(this).attr('id')
    else
      $('.alteration-info-fields-for-' + $(this).attr('id')).remove()

    $('#measurement-table-' + $(this).attr('id')).hide()

  $('#manufacturer').on 'change', ->
    $('.manufacturer-id').val($(this).val())
