function alteration_services_select2() {
  $('.service-select').select2({
    tags: true,
    placeholder: 'Select service',
    allowClear: true,
    width: '100%',
    minimumResultsForSearch: 1,
    ajax: {
      url: '/alteration_services/fetch_services',
      dataType: 'json',
      delay: 250,
      data: function(params) {
        categoryId = $(this).attr('data-category-id')
        return {
          q: {
            name_cont: params.term,
            category_id_eq: categoryId
          },
          page: params.page
        };
      },
      processResults: function(data, params) {
        params.page = params.page || 1;
        return {
          results: data,
          pagination: {
            more: params.page * 30 < data.total_count
          }
        };
      },
      cache: true
    }
  });
}
