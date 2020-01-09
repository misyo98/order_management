$.fabric_customization =
  maybe_fields_for_tuxedo_price: ->
    if $('#category_tuxedo_select').is(":checked")
      $('#tuxedo_price_field').removeClass('hidden')
    else
      $('#tuxedo_price_field').addClass('hidden')

  maybe_dropdown_lists: ->
    $('.using-dropdown-list').each ->
      if $(this).is(':checked')
        $(this).closest('.field').find('.dropdown-list-select-field').removeClass('hidden')
        $(this).closest('.fabric-option').find('.fabric-option-values').addClass('hidden')
      else
        $(this).closest('.field').find('.dropdown-list-select-field').addClass('hidden')
        $(this).closest('.fabric-option').find('.fabric-option-values').removeClass('hidden')

  maybe_fields_for_button_type: ->
    if $('#button_type_select').val() == 'text_button'
      $('.text-button-fields').removeClass('hidden')
    else
      $('.text-button-fields').addClass('hidden')

  editor_maybe_fields_for_button_type: ->
    $('.editor-button-type-select').each ->
      $.fabric_customization.resolve_button_type_fiels($(this))

  resolve_button_type_fiels: (field) ->
    dropdown_value = field.val()
    button_field = field.closest('.field')

    if dropdown_value == 'text_button'
      button_field.find('.text-button-fields').removeClass('hidden')
      button_field.find('.price-button-fields').addClass('hidden')
    else if dropdown_value == 'price_button'
      button_field.find('.price-button-fields').removeClass('hidden')
      button_field.find('.text-button-fields').addClass('hidden')
    else
      button_field.find('.text-button-fields').addClass('hidden')
      button_field.find('.price-button-fields').addClass('hidden')

$(document).ready ->
  $(document).on 'cocoon:after-insert', ->
    $('.selectpicker-for-depends-on').selectpicker({
      title: 'Depends On'
    })

  $('body').on 'change', '.fabric-sgd-currency, .fabric-gbp-currency', ->
    sgd_price = $(this).closest('tbody').find('.fabric-sgd-currency')
    gbp_price = $(this).closest('tbody').find('.fabric-gbp-currency')

    sgd_price.attr('name', sgd_price.attr('name').replace(/(\[SGD\])/, "[price][SGD]")) unless sgd_price.attr('name').includes('[price][SGD]')
    gbp_price.attr('name', gbp_price.attr('name').replace(/(\[GBP\])/, "[price][GBP]")) unless gbp_price.attr('name').includes('[price][GBP]')

  $('body').on 'change', '.category-tuxedo-sgd-currency, .category-tuxedo-gbp-currency', ->
    sgd_price = $(this).closest('tbody').find('.category-tuxedo-sgd-currency')
    gbp_price = $(this).closest('tbody').find('.category-tuxedo-gbp-currency')

    sgd_price.attr('name', sgd_price.attr('name').replace(/(\[SGD\])/, "[tuxedo_price][SGD]")) unless sgd_price.attr('name').includes('[tuxedo_price][SGD]')
    gbp_price.attr('name', gbp_price.attr('name').replace(/(\[GBP\])/, "[tuxedo_price][GBP]")) unless gbp_price.attr('name').includes('[tuxedo_price][GBP]')

  $('.selectpicker-for-depends-on').selectpicker({
    title: 'Depends On'
  })

  $.fabric_customization.maybe_fields_for_tuxedo_price()
  $.fabric_customization.maybe_fields_for_button_type()

  $('body').on 'change', '#category_tuxedo_select', ->
    if $(this).is(":checked")
      $('#tuxedo_price_field').removeClass('hidden')
    else
      $('#tuxedo_price_field').addClass('hidden')

  $('body').on 'change', '.using-dropdown-list', ->
    if $(this).is(":checked")
      $(this).closest('.field').find('.dropdown-list-select-field').removeClass('hidden')
      $(this).closest('.fabric-option').find('.fabric-option-values').addClass('hidden')
    else
      $(this).closest('.field').find('.dropdown-list-select-field').addClass('hidden')
      $(this).closest('.fabric-option').find('.fabric-option-values').removeClass('hidden')

  $('body').on 'change', '#button_type_select', ->
    if $(this).val() == 'text_button'
      $('.text-button-fields').removeClass('hidden')
    else
      $('.text-button-fields').addClass('hidden')

  $('body').on 'change', '.editor-button-type-select', ->
    $.fabric_customization.resolve_button_type_fiels($(this))

$(document).on 'change', '#selected-fabric-category', ->
  if $(this).val().length == 0
    $('.fabric-select-prompt').removeClass('hidden')
    $('.fabric-select-prompt').text('You need to select Category from the dropdown below.')
    $('.fabric-group-box').html(null)
  else
    $('.fabric-select-prompt').text('Loading resources...')
    $.ajax
      type: 'GET'
      dataType: 'script'
      url: '/fabric_form'
      data:
        category_id: $('#selected-fabric-category').val()
      success: (response) ->
        $('.fabric-select-prompt').addClass('hidden')
        $('#fabric_tabs, #fabric_options, #fabric_option_values').sortable({
          items : 'ul'
          cursorAt: { left: 0 }
          delay: 100
          update: (e, ui) ->
            table = $(this).attr('id')
            parent_id = $(this).data('id')

            $.ajax
              url: table + '/reorder' + '?parent_id=' + parent_id
              type: 'PATCH'
              data: $(this).sortable('serialize')
          })
        $.fabric_customization.maybe_fields_for_tuxedo_price()
        $.fabric_customization.maybe_dropdown_lists()
        $.fabric_customization.editor_maybe_fields_for_button_type()
      error: (response) ->
        $('.fabric-select-prompt').text("Something went wrong (Status: #{response.status})")
        $.purrError('Invalid Server Response')

$(document).on 'change', '.fabric-tab-title, .fabric-option-title, .fabric-option-value-title', ->
  header = $(this).closest('.nested-fields').find('.fabric-tab-title-header, .fabric-option-title-header, .fabric-option-value-title-header').first()
  title = $(this).val()
  header.text(title)

$(document).on 'click', '#add_currency_button', (e) ->
  e.preventDefault()
  $('.fabric-prices').append('
    <li>
      <div class="price">
        <table>
          <tbody><tr>
            <td>
              <label>
                Currency
              </label>
              <input type="text" name="price_array[][currency]" id="fabric_currency_field" class="form-control mb-2 mr-sm-2" placeholder="Currency" size="35">
            </td>
            <td>
              <label>
                Value
              </label>
              <input type="text" name="price_array[][value]" id="price_array__value" class="form-control mb-2 mr-sm-2" placeholder="Value" size="35">
            </td>
          </tr>
        </tbody></table>
        <br>
        <a id="remove_currency_button" class="btn btn-danger">Remove currency</a>
        <br>
      </div>
    </li>
  ')

$(document).on 'click', '#remove_currency_button', (e) ->
  e.preventDefault()
  $(this).closest('li').find('.price').remove()

$(document).on 'click', '.expand-fabric-box', (e) ->
  e.preventDefault()
  fabric_tab_box = $(this).closest('span').find('.fabric-tab, .fabric-option, .fabric-option-value').first()
  if fabric_tab_box.hasClass('was-hidden')
    $(this).removeClass('fa-caret-square-down')
    $(this).addClass('fa-caret-square-up')
    fabric_tab_box.slideDown(300)
    fabric_tab_box.removeClass('was-hidden')
  else
    $(this).removeClass('fa-caret-square-up')
    $(this).addClass('fa-caret-square-down')
    fabric_tab_box.slideUp(300)
    fabric_tab_box.addClass('was-hidden')

$(document).ready ->
  $('body').on 'click', '#submit_fabric_construction_form', ->
    $('.fabric-form-group').find('input').each ->
      if $(this).val() == ''
        $(this).addClass('fabric-error-field')
      else
        $(this).removeClass('fabric-error-field')

  $('body').on 'change', 'input', ->
    if $(this).val() == ''
      $(this).addClass('fabric-error-field')
    else
      $(this).removeClass('fabric-error-field')

  $('body').on 'change', '.image-url-field', ->
    image_url = $(this).val()
    image_field = $(this).closest('.fabric-option-value').find('.image-field')

    if image_url == ''
      image_field.attr('src', '')
      image_field.addClass('hidden')
    else
      image_field.attr('src', image_url)
      image_field.removeClass('hidden')

  if $('#index_table_fabric_brands').length || $('#index_table_fabric_books').length
    $('#index_table_fabric_brands, #index_table_fabric_books').sortable({
      items: 'tr'
      cursorAt: { left: 0 }
      delay: 100
      })

    $(document).on 'click', '#submit_order_button', (e) ->
      e.preventDefault()
      table_name = $(this).data('tableName')

      $.ajax
        url: "#{table_name}/reorder"
        type: 'PATCH'
        dataType: 'script'
        data: $("#index_table_#{table_name}").sortable('serialize')
