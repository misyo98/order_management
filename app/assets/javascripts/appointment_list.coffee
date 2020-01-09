$(document).on 'ready turbolinks:load', ->
  $.appointments.enableSelect2()
  $('.best_in_place').best_in_place()

  $('body').on 'click', '.approve-changes', ->
    $.appointments.approveChanges($(this))

  $('body').on 'click', "#set-as-default-service", ->
    $.ajax
      url: $(this).attr('data-url')
      dataType: 'script'
      type: 'GET'
      data:
        filter:
          calendar_ids: $('#filter-id').val()

  $('body').on 'click', '.remove-selected-email', ->
    $(this).closest('td').find('.customer-select').val(null).trigger('change')
    $(this).closest('tr').find('td.purchase-field').html('<span class="label flat-label-fail">No</span>')

  $('body').on 'select2:selecting', '.customer-select', (e) ->
    $(this).closest('tr').find('td.purchase-field').html('<span class="label flat-label-success">Yes</span>')

  $('body').on 'click', '.dropdown-toggle', (e) ->
    $(this).closest('.has_nested').addClass('open')

  # $('body').on 'best_in_place:update', '.purchase-reason-dropdown', ->
  #   selected_reason = $(this).find('[data-bip-type="select"]').data('bip-value')
  #   id = $(this).closest('tr').data('appt-id')

  #   if selected_reason == 'wedding_browsing'
  #     $.appointments.weddingModal(id)

$.appointments =
  toggleTabs: (target) ->
    tabs = ['browsers_and_other', 'no_shows_and_cancelled', 'outfitters', 'dropped']
    for t in tabs
      table = "#{t}-table"
      if target == t
        $("[data-target='#{table}']").closest('li').addClass('active')
        $("##{table}").addClass('in active')
      else
        $("[data-target='#{table}']").closest('li').removeClass('active')
        $("##{table}").removeClass('in active')

  enableSelect2: () ->
    $('.customer-select').each ->
      day = $(this).closest('tr').find('.app-day').text()
      $(this).select2
        theme: 'bootstrap'
        placeholder: "Select a customer"
        width: '100%'
        minimumResultsForSearch: 0

        ajax:
          url: $(this).attr('data-api-url')
          dataType: 'json'
          headers:
            'Accept': 'application/json'
            'Content-Type': 'text/plain'
          type: 'GET'
          delay: 250
          data: (params) ->
            q: params.term
            page: params.page
            day: day

          processResults: (data, params) ->
            params.page = params.page or 1
            {
              results: data
              pagination: more: params.page * 30 < data.total_count
            }
          cache: true

  approveChanges: (selector, forceUpdate = false) ->
    appointmentTr = selector.closest('tr')
    adminUser = selector.data('admin-user')
    customerEmail = appointmentTr.find('.customer-select').val()
    reason = appointmentTr.find('[data-bip-attribute="no_purchase_reason"]').data('bip-value')
    comment = appointmentTr.find('[data-bip-attribute="follow_up_status"]').data('bip-value') || ''

    if reason == 'no_reason' && $.isEmptyObject(customerEmail) && !forceUpdate
      if adminUser
        $.appointments.displayAdminError(selector, 'Either reason or customer email must be filled')
      else
        $.purrError('Either reason or customer email must be filled')
    else if reason == 'other' && comment.length <= 0
      $.purrError('Selected reason requires a comment.')
    else
      updatedByOutfitter = 1
      url = selector.data('api-url')
      outfitterId = selector.data('outfitter-id')

      $.ajax
        type: 'PATCH'
        dataType: 'json'
        url: url
        data:
          'object Object':
            customer_email: customerEmail
            updated_by_outfitter: updatedByOutfitter
            order_tool_outfitter_id: outfitterId
          force_update: forceUpdate
        success: (data) ->
          $.purrSuccess()
          appointmentTr.remove()
        error: (data) ->
          errors = JSON.parse(data.responseText)

          messages = []
          $.each Object.keys(errors), (index, key) ->
            $.each errors[key], (field, error) ->
              $.each error, (key, error_value) ->
                messages.push("#{field} - #{error_value.message}")

          if adminUser
            $.appointments.displayAdminError(selector, messages)
          else
            $.purrError(messages)

  displayAdminError: (original_selector, message) ->
    swal {
      html: true
      title: 'Cannot remove from list'
      text: "#{message}"
      type: 'info'
      showCancelButton: true
      confirmButtonClass: 'btn-success'
      confirmButtonText: 'Remove Anyway'
      cancelButtonText: 'Cancel'
      closeOnConfirm: true
      closeOnCancel: true
    }, (isConfirm) ->
      if isConfirm
        $.appointments.approveChanges(original_selector, true)

  weddingModal: (id) ->
    modalContainer = document.createElement('div')
    modalContainer.classList.add('wedding-modal-wrapper')
    modalContainer.innerHTML =
      "<div class='modal fade' id='weddinDateModal' tabindex='-1' role='dialog' aria-hidden='true'>
        <div class='modal-dialog' role='document'>
          <div class='modal-content'>
            <div class='modal-header'>
              <h5 class='modal-title'>Please, select wedding date</h5>
              <button type='button' class='close' data-dismiss='modal' aria-label='Close'>
                <span aria-hidden='true'>&times;</span>
              </button>
            </div>
            <div class='modal-body'>
              <div class='form-group row'>
                <div class='col-sm-10'>
                  <input type='text' class='form-control form-control-sm datepicker' id='wedding-date-input' placeholder='select date'>
                </div>
              </div>
            </div>
            <div class='modal-footer'>
              <button type='button' class='btn btn-secondary' data-dismiss='modal'>Close</button>
              <button type='button' class='btn btn-primary save-wedding-date'>Save changes</button>
            </div>
          </div>
        </div>
      </div>"
    document.body.appendChild(modalContainer)
    $('.save-wedding-date').on 'click', ->
      selectedDate = $('#wedding-date-input').val()
      $('[data-bip-activator="##{id}-wedding-date-field"]').attr('data-bip-value', selectedDate)
      $('[data-bip-activator="##{id}-wedding-date-field"]').attr('data-test', selectedDate)
    modal = $(modalContainer).find('.modal')
    modal.on 'hidden.bs.modal', ->
      $('.wedding-modal-wrapper').remove()
    modal.modal('show')


