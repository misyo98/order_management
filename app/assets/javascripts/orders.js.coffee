stateTriggerHandler = (element) ->
  $.ajax
    type: 'PATCH'
    dataType: 'script'
    url: element.attr('data-url')
    data:
      state_event: element.attr('data-state-event')

$(document).ready ->
  #function for removing all styles from scopes on line_items index page
  if $('body').hasClass('line_items')
    setTimeout (->
      $('ul.scopes.table_tools_segmented_control').removeAttr('style')
    ), 5

  #function for triggering state change for item
  $('body').on 'click', '.state-trigger', ->
    element = $(this)
    if element.data('swal')
      swal {
        title: element.data('swal-title') || 'Are you sure?'
        text: element.data('swal-text') || ''
        type: element.data('swal-type') || 'warning'
        showCancelButton: true
        confirmButtonClass: element.data('swal-confirm-btn-class') ||'btn-warning'
        confirmButtonText: 'Yes'
        cancelButtonText: 'No'
        closeOnConfirm: true
        closeOnCancel: true
      }, (isConfirm) ->
        if isConfirm
          stateTriggerHandler(element)
    else
      stateTriggerHandler(element)


  #function for updating item fields after changing fabric state
  $('body').on 'ajax:success', '.best_in_place[data-bip-attribute="fabric_state"]', (e) ->
    url = $(this).attr('data-url')

    $.ajax
      type: 'GET'
      dataType: 'script'
      url: url

  #function for submitting manufacturer order number
  $('body').on 'click', '#state-error-submit-button', (e) ->
    e.preventDefault()
    input = $('#manufacturer-number-error-modal')
    m_order_number = input.val()
    url = input.attr('data-url')
    id = input.attr('data-id')

    $.ajax
      type: 'PATCH'
      dataType: 'json'
      url: url
      data:
        line_item:
          m_order_number: m_order_number
      success: (data) ->
        target = ".best_in_place[data-manufacturer-order-number-id=" + id + "]"
        $(target).text(m_order_number)
        state = $('#line_item_' + id).find('a.manufacturer-order-created')
        state.click()
        $('#state-error-modal').modal('hide')
      error: (data) ->
        error_message = data.responseJSON['errors']['m_order_number'].join()
        input.addClass('error_field')
        ('<li class="error_text">'+ error_message + '</li>').prependTo($('#state-error-modal-body'))
        # $('<span class="error_text">'+ error_message + '</span>').insertAfter(input)
        # $.purrError(error_message)

  $('body').on 'change', '.item-state-select', (e) ->
    input = $(this)
    default_state = input.attr('data-default')
    url = input.attr('data-url')
    state = input.val()
    swal {
      title: 'Are you sure you want to change state?'
      text: 'All your actions will be saved in state history'
      type: 'warning'
      showCancelButton: true
      confirmButtonClass: 'btn-success'
      confirmButtonText: 'Change state'
      cancelButtonText: 'Cancel'
      closeOnConfirm: true
      closeOnCancel: false
    }, (isConfirm) ->
      if isConfirm
        $.ajax
          type: 'PATCH'
          dataType: 'script'
          url: url
          data:
            line_item:
              state: state
          success: ->
            $.purrSuccess()

      else
        swal 'Cancelled', 'State is not changed'
        input.val(default_state)

  #function for destroying line items
  $('body').on 'click', '.state-button.delete', (e) ->
    url = $(this).attr('data-url')
    id  = $(this).attr('data-id')
    swal {
      title: 'Are you sure you want to destroy this item?'
      text: 'You wont be able to get it back'
      type: 'error'
      showCancelButton: true
      confirmButtonClass: 'btn-danger'
      confirmButtonText: 'Destroy'
      cancelButtonText: 'Cancel'
      closeOnConfirm: false
      closeOnCancel: false
    }, (isConfirm) ->
      if isConfirm
        $.ajax
          type: 'DELETE'
          dataType: 'json'
          url: url

          success: ->
            swal "Deleted!", "Your imaginary file has been deleted.", 'success'
            $("#line_item_#{id}").fadeOut 500, ->
              $("#line_item_#{id}").remove()
      else
        swal 'Cancelled', 'Item is safe'

  # make line_items table sticky
  # $('#index_table_line_items').find('thead').addClass('sticked_head')
  # $('#index_table_line_items').find('tbody').addClass('sticked_body')


  #function for submitting refunded amount
  $('body').on 'click', '#refund-submit-button', (e) ->
    amount = $('#refund-amount').val()
    reason = $('#refund-reason').val()
    comment = $('#refund-comment').val()
    url = $('#refunded-field').attr('data-url')
    id = $('#refunded-field').attr('data-id')

    $.ajax
      type: 'PATCH'
      dataType: 'script'
      url: url
      data:
        refund:
          amount: amount
          reason: reason
          comment: comment

  #function for preventing submitting Line Items page on click Enter
  $('body').on 'keypress', (e) ->
    keyCode = e.keyCode or e.which
    if e.keyCode == 13 and e.target.id == 'refund-amount'
      e.preventDefault()
      $('#refund-submit-button').click()

    #drag table line items index page
  $('body').on 'click', '.reorder-columns', ->
    if $(this).attr('data-state') == 'off' then $(this).attr('data-state', 'on') else $(this).attr('data-state', 'off')
    state = $(this).attr('data-state')

    $('.index_table').find('thead').find('th').each (i) ->
      if state == 'on'
        $(this).addClass('reordable')
      else
        $(this).removeClass('reordable')
    if state == 'on' then $(this).html('Stop') else $(this).html('Reorder')
    #dragtable configs
    $('.index_table').dragtable

      persistState: (table) ->

        table.el.find('th').each (i) ->
          text = $(this).text().replace(/(\r\n|\n|\r)/gm, "")
          text = text.replace(/\s/g,'')
          return true if text == '' || text == 'Id'

          table.sortOrder[$(this).text()] = i - 1

        $.ajax
          type: 'PATCH'
          dataType: 'script'
          url: $('#reorder-url').attr('data-path')
          data:
            columns: table.sortOrder
            scope: $('#reorder-url').attr('data-scope')
            page: $('#reorder-url').attr('data-page')

      beforeStart: (table) ->
        if state == 'on' then return true else return false

      dragaccept: '.reordable'
