$(document).ready ->
  $('#select-fabric-info').select2
    placeholder: 'Select fabric info'
    minimumInputLength: 2
    width: '100%'

    ajax:
      url: '/fabric_infos/get_fabric_infos'
      dataType: 'json'
      delay: 250
      data: (params) ->
        q:
          fabric_code_cont: params.term
        page: params.page

      processResults: (data, params) ->
        params.page = params.page or 1
        {
          results: data
          pagination: more: params.page * 30 < data.total_count
        }
