$(document).ready ->
  $('.tags-select').select2
    tags: true
    placeholder: 'Select tag'
    width: '100%'
    minimumResultsForSearch: 1

    ajax:
      url: '/tags'
      dataType: 'json'
      delay: 250
      data: (params) ->
        q:
          name_cont: params.term
        page: params.page

      processResults: (data, params) ->
        params.page = params.page or 1
        {
          results: data
          pagination: more: params.page * 30 < data.total_count
        }
      cache: true

  $('body').on 'click', '.assign-tags', ->
    $($(this).attr('data-target')).removeClass 'hidden'
    $(this).addClass 'hidden'

  $('body').on 'click', '.cancel-update-tags', ->
    form = $($(this).attr('data-target'))
    form.addClass 'hidden'
    form.siblings('.assign-tags').removeClass 'hidden'

  $('body').on 'click', '.update-tags', (e) ->
    $.ajax
      url: $(this).attr('data-url')
      dataType: 'script'
      type: 'PATCH'
      data:
        tags: $($(this).attr('data-target')).val()

