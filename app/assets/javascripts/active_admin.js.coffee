#= require active_admin/base
#= require bootstrap-sprockets
#= require active_admin/select2
#= require jquery.fancybox.js
#= require jquery.dotdotdot.js
#= require jquery.remotipart
#= require best_in_place
#= require best_in_place.jquery-ui
#= require jquery.purr
#= require best_in_place.purr
#= require jquery.dragtable.js
#= require sweetalert.min.js
#= require pusher.min.js
#= require active_admin_sidebar
#= require vex.combined.min.js
#= require bootstrap-select.min.js
#= require jquery-ui/widget
#= require jquery-ui/sortable
#= require active_bootstrap_skin
#= require cocoon
#= require tags
#= require alteration_services_select2
#= require fabric_infos
#= require custom_validations
#= require measurements_csv
#= require fabric_editor
#= require fitting_garments_csv

# $(document).ajaxStart(->
#   return unless $('.loader-field').length
#   $('.loader-field').removeClass('hidden')
#   $('.container').css({ 'opacity' : 0.5 })
# ).ajaxStop ->
#   return unless $('.loader-field').length
#   $('.loader-field').addClass('hidden')
#   $('.container').css({ 'opacity' : 1 })

$(document).ajaxStart(->
  if $('#fabric_management_body').length
    $('.fabric-manager-status').bind 'ajax:success', ->
      estimated_restock_date_field = $(this).closest('tr').find('.estimated-restock-date')

      if $(this).data('bip-value') == 'discontinued'
        estimated_restock_date_field.closest('span').addClass('hidden')
        estimated_restock_date_field.find('.bip-estimated-restock-date').data('bip-value', 'Unknown')
        estimated_restock_date_field.find('.bip-estimated-restock-date').html('Unknown')
      else
        estimated_restock_date_field.closest('span').removeClass('hidden')
)

(($) ->
  $.fn.serializeFormJSON = ->
    response = {}
    formArray = @serializeArray()
    $.each formArray, ->
      if response[@name]
        if !response[@name].push
          response[@name] = [ response[@name] ]
        response[@name].push @value or ''
      else
        response[@name] = @value or ''
      return
    response

  return
) jQuery


vex.defaultOptions.className = 'vex-theme-flat-attack';

updateCallList = (input) ->
  if input.hasClass('call-list-status-input')
    status = input.val()
    date = undefined
  else
    date = input.val()
    status = undefined

  url = input.attr('data-url')

  $.ajax
    url: url
    type: 'PATCH'
    dataType: 'json'
    data:
      customer:
        status: status
        last_contact_date: date
    success: ->

find_ths = ->
  array = []

  array.push $('th:contains(\'measurement\')').index() + 1
  array.push $('th:contains(\'category\')').index() + 1

  if $('th:contains(\'alteration 1\')').length == 1
    array.push $('th:contains(\'garment post alteration\')').index() + 1
  else
    array.push $('th:contains(\'final garment\')').index() + 1
  array

triggerChecked = (checkbox) ->
  name = checkbox.attr('name')
  tds = $("td:contains(" + name + ")")

  if checkbox.is(":checked")
    tds.each ->
      tr = $(this).closest('tr')
      markReadonlies(tr)

      tr.find('input').each ->
        unless $(this).hasClass('disabled_input')
          $(this).prop('disabled', false)

      tr.find('select').each ->
        unless $(this).hasClass('disabled_input')
          $(this).prop('disabled', false)

      tr.removeClass('hidden')
  else
    tds.each ->
      tr = $(this).closest('tr')

      tr.find('input').prop('disabled', true)
      tr.find('select').prop('disabled', true)

      tr.addClass('hidden')

hideStatuses = (checkbox) ->
  id = checkbox.attr('id')
  target = $('#profile-category-' + id)
  target_input = target.find($('select'))

  if checkbox.is(":checked")
    target_input.prop('disabled', false)
    target.removeClass('hidden')
  else
    target_input.prop('disabled', true)
    target.addClass('hidden')

hideTables = (checkbox) ->
  id = checkbox.attr('id')
  table = $('.measurement-table-' + id).show()

  if checkbox.is(":checked") then table.show() else table.hide()

$.purrSuccess = (msg = null) ->
  msg ||= 'Updated Successfully'
  container = jQuery(BestInPlaceEditor.defaults.purrSuccessContainer).html(msg)
  container.purr(removeTimer: 900)

$.purrError = (messages) ->
  container = jQuery(BestInPlaceEditor.defaults.purrErrorContainer).html(messages)
  container.purr(removeTimer: 1500)

markReadonlies = (tr) ->
  $('#alteration_pants_calf, #alteration_chinos_calf, #alteration_waistcoat_waist_button_position').prop('readonly', true)
  $('#alteration_waistcoat_waistcoat_1st_button_position').prop('readonly', true) unless $('#without_extra_fields').val() == 'true'

$(document).ready ->
  $('#fabric_settings').hover (->
    $(this).closest('.has_nested').addClass('open')
  )

  $('.show_body_measurements').on 'click', ->
    if $('.body').hasClass('hidden')
      $('.show_body_measurements').text('Hide Body')
      $('.body').removeClass('hidden')
      $('.body-value-field').removeClass('hidden')
    else
      $('.show_body_measurements').text('Show Body')
      $('.body').addClass('hidden')
      $('.body-value-field').addClass('hidden')

  $('.show_validations').on 'click', ->
    if $('.checks').hasClass('hidden')
      $('.show_validations').text('Hide Validations')
      $('.checks').removeClass('hidden')
      $('.error-message').closest('td').closest('tr').addClass('error_field')
    else
      $('.error_field').removeClass('error_field')
      $('.error-message').closest('td').closest('tr').removeClass('error_field')
      $('.show_validations').text('Show Validations')
      $('.checks').addClass('hidden')

  # custom filters for Orders Table
  $('body').on 'click', '.orders-custom-filters-submit', (e) ->
    e.preventDefault()

    url            = $('#orders_q_search').data('url')
    method         = $('#orders_q_search').data('method')
    search_data    = {}

    $('#orders_q_search input[type=search]').each (index, obj) ->
      search_data[obj.name] = obj.value

    $.ajax
      type: method
      dataType: 'html'
      url: url
      data:
        search_data
      success: (responseData) ->
        document.open();
        document.write(responseData);
        document.close();

  BestInPlaceEditor.defaults.purrErrorContainer = "<span class='bip-flash-error'></span>";
  BestInPlaceEditor.defaults.purrSuccessContainer = "<span class='bip-flash-success'></span>";
  #prepare best in place editing
  $('.best_in_place').best_in_place()

  #prepare pretty selectpicker for forms
  $('.selectpicker').selectpicker({
    style: 'btn-default',
    size: 10
  });

  #function for initial checking checked checkboxes
  setTimeout (->
    $('.alteration-categories').each ->
      if $(this).is(":checked")
        $(this).click().click()
        hideStatuses($(this))
  ), 100

  $('.alteration-services-table tbody').sortable update: (e, ui) ->
    orderParams = window.location.search.slice(1)

    unless orderParams.length
      $.ajax
        url: $('table.alteration-services-table').data('url')
        type: 'PATCH'
        data: $(this).sortable('serialize')

  #purr notifications
  $(document).on 'best_in_place:success', (event, request, error) ->
    $.purrSuccess()

  $(document).on 'best_in_place:error', (event, request, error) ->
    errors = JSON.parse(request.responseText)

    messages = []
    $.each Object.keys(errors), (index, key) ->
      $.each errors[key], (field, error) ->
        $.each error, (key, error_value) ->
          messages.push("#{field} - #{error_value.message}")

    $.purrError(messages)

  $.datepicker.setDefaults(
    dateFormat: "yy-mm-dd"
  )

  #function for submitting inputs on call list index page
  typingTimer = undefined
  doneTypingInterval = 200

  $('body').on 'keyup change', '.call-list-status-input, .call-list-last-contact-date', ->
    input = $(this)

    clearTimeout(typingTimer)

    typingTimer = setTimeout (->
      updateCallList(input)
    ), doneTypingInterval

  #function for painting alteration table rows red if > 5
  $('.col.col-altered').each ->
    val = parseFloat($(this).html())
    submissions = parseFloat($(this).prev('.col-total_meas_submissions').find('.total-submissions').text())

    if val > 25 && submissions >= 5
      $(this).closest('tr').addClass('mark-red')

  $('.col-due_date .mark-red').each ->
    $(this).closest('tr').addClass('delayed')

  #function to fix settings dropdown
  dropdown_link_html = '<a href="#" class="dropdown-toggle" id="dropdownMenu1" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">Settings<span class="caret"></span></a>'
  dropdown_accounting_link_html = '<a href="#" class="dropdown-toggle" id="dropdownMenu2" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">Accounting<span class="caret"></span></a>'
  dropdown_alteration_link_html = '<a href="#" class="dropdown-toggle" id="dropdownMenu3" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">Alteration<span class="caret"></span></a>'
  dropdown_appointment_link_html = '<a href="#" class="dropdown-toggle" id="dropdownMenu4" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">Appointment list<span class="caret"></span></a>'
  dropdown_fabric_settings_link_html = '<a href="#" class="dropdown-toggle2" id="dropdownMenu5" data-toggle="dropdown" aria-haspopup="true" aria-expanded="true">Fabric Settings<span class="caret"></span></a>'
  $('#settings').find('a').first().replaceWith(dropdown_link_html)
  $('#settings').find('ul').addClass('dropdown-menu')
  $('#settings').find('ul').attr('aria-labelledby', 'dropdownMenu1')
  $('#accountings').find('a').first().replaceWith(dropdown_accounting_link_html)
  $('#accountings').find('ul').addClass('dropdown-menu')
  $('#accountings').find('ul').attr('aria-labelledby', 'dropdownMenu2')
  $('#alterations').find('a').first().replaceWith(dropdown_alteration_link_html)
  $('#alterations').find('ul').addClass('dropdown-menu')
  $('#alterations').find('ul').attr('aria-labelledby', 'dropdownMenu3')
  $('#appointment_list').find('a').first().replaceWith(dropdown_appointment_link_html)
  $('#appointment_list').find('ul').addClass('dropdown-menu')
  $('#appointment_list').find('ul').attr('aria-labelledby', 'dropdownMenu4')
  $('#fabric_settings').find('a').first().replaceWith(dropdown_fabric_settings_link_html)
  $('#fabric_settings').find('ul').addClass('dropdown-menu')
  $('#fabric_settings').find('ul').attr('aria-labelledby', 'dropdownMenu5')

  #function for coloring remaining cogs table NO MATCH fields in red
  $('#index_table_remaining_cogs tbody .col.col-matching_order_item').each ->
    if $(this).text() == 'NO MATCH'
      $(this).closest('tr').addClass('mark-red')

  $('.fancybox').fancybox()

  $('.hide-measurements').on 'click', ->
    visible_ths = find_ths()
    table = $('.measurements_index_table')

    table.find('th').each ->
      column = $(this).html()
      value = $("th:contains(" + column + ")").index() + 1
      if value in visible_ths
        return true

      element_td = "td:nth-child(" + value + ")"
      element_th = "th:nth-child(" + value + ")"
      $(element_td + ',' + element_th, table).toggle()

    $(this).html(if $(this).html() == 'Hide Columns' then 'Show Columns' else 'Hide Columns')

  $('body').on 'change', '#fabric_manager_status', (e) ->
    status = $('#fabric_manager_status').val()

    if status == 'discontinued'
      $('#fabric_manager_estimated_restock_date').val('')
      $('#fabric_manager_estimated_restock_date').addClass('hidden')
    else
      $('#fabric_manager_estimated_restock_date').removeClass('hidden')

  #script for hiding unchecked categories on customers profile
  $('body').on 'change', '.alteration-categories', (e) ->
    triggerChecked($(this))
    hideStatuses($(this))

  #initialize clipboard for copying measurements table
  if $('#copy_button').length > 0
    new Clipboard('#copy_button')

  $('body').on 'change', '.profile-categories', ->
    hideTables($(this))

  #functions for hovering alteration comment
  if $('.hover-text').length > 0
    $('.hover-text').dotdotdot(
      after: "<a href='javascript:;' class='readmore'>Read more</a>"
      height: 40
    )

  #functions for hovering alteration comment
  $('.readmore').on 'click', ->
    target = $(this).closest('.hover-text')
    parent =
      if $(this).parents('.hover-text-cont').length > 0
        $(this).parents('.hover-text-cont')
      else
        target.parent('td')
    content = target.triggerHandler('originalContent').text()
    link = " <a href='javascript:;' class='hide-text'>Hide</a>"
    wrapper = "<span class='wrap-comment'>" + content + link + "</span>"
    target.hide()

    parent.append(wrapper)

  #functions for hovering alteration comment
  $('body').on 'click', '.hide-text', ->
    $(this).parent('span.wrap-comment').siblings('span.hover-text').show()
    $(this).parent('span.wrap-comment').remove()

  #function for removing unselected columns dynamically on line items index page
  $('body').on 'click', '.submit-column-visibility', ->
    data_hash = {}
    url = $(this).attr('data-url')

    $(this).closest('.modal-content').find('.column-for-select').each ->
      data_hash[$(this).attr('id')] = $(this).is(":checked")
      # this is here for coffee not to return previous row
      check = true

    $.ajax
      type: 'PATCH'
      url: url
      dataType: 'html'
      data:
        columns: data_hash
      success: (response) ->
        location.reload()

  #function for adding formatting classes for accounting table
  if $('#index_table_accounting').length
    $('#main_content_wrapper').css('width','100%');
    $('.paginated_collection_contents').addClass('overflow-x-auto')

  # function for triggering custom batch edit action on remaining cogs page
  $('body').on 'click', '.custom_batch_action', ->
    url = $(this).attr('data-url')

    $.ajax
      type: 'GET'
      dataType: 'script'
      url: url

  #function for batch updating cust bucket on remaining cogs page
  $('body').on 'click', '.batch-update-buckets', ->
    value = $('#selected-cost-bucket-id').val()
    url   = $(this).attr('data-url')
    selected_cogs = []
    $('.collection_selection:checked').each ->
      selected_cogs.push($(this).val())

    $.ajax
      type: 'PATCH'
      dataType: 'script'
      url: url
      data:
        cog_ids: selected_cogs
        cost_bucket_id: value

  #function for selecting-deselecting all columns
  $('body').on 'click', '.columns-actions-btn', ->
    check = $(this).hasClass('columns-select-all')

    $(this).closest('.modal-body').find('.column-for-select').each ->
      $(this).prop('checked', check)

  #function for marking in red customer comment fields in order table
  $('.col-customer_note_woocommerce').each ->
    if $(this).text().length
      $(this).addClass('red-field')

  $('body').on 'change', '.alteration-info-checkmark', (e) ->
    container = $(this).closest('.form-group').find('.alteration-info-field')
    if $(this).is(':checked')
      container.removeClass('hidden')
    else
      container.addClass('hidden')
      container.find('input').val('')

  # section for Invoices logic
  $('body').on 'change', '.summary-check-box', (e) ->
    if $('.summary-check-box:checkbox:checked').length
      $('.create-invoice-button').removeClass('hidden')
    else
      $('.create-invoice-button').addClass('hidden')

  $('body').on 'click', '.create-invoice-button', (e) ->
    e.preventDefault();

    summaryIds = $('.summary-check-box:checkbox:checked').map(->
      @value
    ).get()

    $.ajax
      type: 'POST'
      dataType: 'script'
      url: '/invoices'
      data:
        invoice:
          alteration_summary_ids: summaryIds


  $('body').on 'change', '#select_all_summaries_for_invoice', ->
    if $(this).is(':checked')
      $('.create-invoice-button').removeClass('hidden')
      $('.summary-check-box').prop('checked', true)
    else
      $('.create-invoice-button').addClass('hidden')
      $('.summary-check-box').prop('checked', false)

  $('body').on 'change', '.summary-invoice-check-box', (e) ->
    checked = e.target.checked

    if checked
      accept = confirm('Are you sure you want to add alteration to invoice?')
      if !accept
        e.target.checked = !checked
        return
    else
      accept = confirm('Are you sure you want to delete alteration from invoice?')
      if !accept
        e.target.checked = checked
        return

    e.preventDefault();
    id = $(this).attr('data-id')

    if $(this).is(':checked')
      url = "/invoices/#{id}/add_summary"
      type = 'PATCH'
    else
      url = "/invoices/#{id}/remove_summary"
      type = 'DELETE'

    $.ajax
      type: type
      dataType: 'script'
      url: url
      data:
        alteration_summary_id: $(this).val()

  # function for showing to be fixed profiles in popover
  if $('#current_user').length
    $.ajax
      type: 'GET'
      dataType: 'script'
      url: '/users/to_be_fixed_profiles'

  $('.tier-category-price').on 'change', ->
    data = $(this).data()

    $.ajax
      type: 'PATCH'
      dataType: 'script'
      url: "/fabric_tiers/#{data['fabricTierId']}/update_tier_category_price"
      data:
        fabric_category_id: data['fabricCategoryId']
        currency: data['currency']
        value: $(this).val()

$(document).on 'change', '#user_role_input > #user_role', (e) ->
  if $(this).val() == 'tailor'
    $('#user_alteration_tailor_input').removeClass('hidden')
    $('#user_inhouse_input').removeClass('hidden')
  else
    $('#user_alteration_tailor_id').val('')
    $('#user_inhouse_input').val('')
    $('#user_alteration_tailor_input').addClass('hidden')
    $('#user_inhouse_input').addClass('hidden')

$(document).on 'change', '#user_role_input > #user_role', (e) ->
  if $(this).val() == 'outfitter'
    $('#user_can_send_delivery_emails_input').removeClass('hidden')
  else
    $('#user_can_send_delivery_emails_input_id').val('')
    $('#user_can_send_delivery_emails_input').addClass('hidden')

$(document).on 'click', '.remove-tailor-service', (e) ->
  e.preventDefault()
  $(this).closest('tr').remove()

$(document).on 'click', '.create-tailor-service', (e) ->
  service_category_id = $(this).closest('tr').find('#service-category').val()
  service_name = $(this).closest('tr').find('.service-select').val()
  service_price = $(this).closest('tr').find('#service-price').val()
  service_author_id = $(this).closest('tr').find('#service-author').val()
  service_tailor_id = $(this).closest('tr').find('#alteration-tailor-id').val()
  $(this).addClass("service-create-#{service_name.split(' ').join('')}")
  e.preventDefault()

  $.ajax
    type: 'GET'
    dataType: 'json'
    url: '/alteration_services/find_service_tailor'
    data:
      q:
        alteration_service_name_eq: service_name
        alteration_tailor_id_eq: service_tailor_id
        price_eq: null

    success: (data) ->
      id = null
      if data.id
        id = data.id

      $.ajax
        type: 'POST'
        dataType: 'script'
        url: '/alteration_services'
        data:
          alteration_service:
            category_id: service_category_id
            name: service_name
            order: 100
            custom: true
            author_id: service_author_id
            alteration_service_tailors_attributes:
              '0':
                id: id
                alteration_tailor_id: service_tailor_id
                price: service_price

$(document).on 'click', '.delete-alteration-button', (e) ->
  e.preventDefault()

  url = $(this).attr("href")
  customer_url = $(this).data('customer-id')
  latest_alteration = $(this).data('latest-category-alteration')

  if latest_alteration == 'yes'
    swal {
      title: 'Delete Alteration'
      text: 'Do you want to reset the final garment measurements to what they were before the alteration?'
      type: 'warning'
      showCancelButton: true
      confirmButtonClass: 'btn-success'
      confirmButtonText: 'Yes'
      cancelButtonText: 'No'
      closeOnConfirm: true
      closeOnCancel: true
      allowOutsideClick: false
    }, (isConfirm) ->
      if isConfirm
        $.ajax
          type: 'DELETE'
          dataType: 'script'
          url: url
          data:
            delete_with_revert: true

          success: ->
            $.purrSuccess('Deleted summary and reverted measurements!')

      else
        $.ajax
          type: 'DELETE'
          dataType: 'script'
          url: url

          success: ->
            $.purrSuccess('Deleted summary without reverting measurements!')

  else
    swal {
      title: 'Delete Alteration'
      text: 'Do you want to remove this alteration? (Measurements will not be reverted back)'
      type: 'warning'
      showCancelButton: true
      confirmButtonClass: 'btn-success'
      confirmButtonText: 'Yes'
      cancelButtonText: 'No'
      closeOnConfirm: true
      closeOnCancel: true
      allowOutsideClick: false
    }, (isConfirm) ->
      if isConfirm
        $.ajax
          type: 'DELETE'
          dataType: 'script'
          url: url

          success: ->
            $.purrSuccess('Deleted summary!')
