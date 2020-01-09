// For correctly displaying modals on iPad
// Run it before modal opening
$.removeScrollingTouch = function(){
  $('html').addClass('not-scroll');
}

// Run it after modal closing
$.addScrollingTouch = function(){
  $('html').removeClass('not-scroll');
}

var stateTriggerHandler;

stateTriggerHandler = function(element) {
  return $.ajax({
    type: 'PATCH',
    dataType: 'script',
    url: element.attr('data-url'),
    data: {
      state_event: element.attr('data-state-event')
    }
  });
};

function batchItemStateTrigger(){
  var item_ids;
  item_ids = [];
  $('.collection_selection:checked').each(function() {
    return item_ids.push($(this).val());
  });
  if (item_ids.length > 0) {
    return $.ajax({
      type: 'GET',
      dataType: 'script',
      url: $('#batch-events-url').attr('data-path'),
      data: {
        ids: item_ids
      }
    });
  } else {
    return $('.action_items').find('.batch-state-trigger').each(function() {
      return $(this).remove();
    });
  }
}

$(function() {
  // function for rendering available batch event for selected items
  if ($('body').hasClass('line_items')) {
    $('body').on('change', '.collection_selection, #collection_selection_toggle_all', function() {
      batchItemStateTrigger();
    });
  }


  var dropdown_accounting_link_html, dropdown_link_html;
  if ($('body').hasClass('line_items')) {
    setTimeout((function() {
      return $('ul.scopes.table_tools_segmented_control').removeAttr('style');
    }), 5);
  }

  $('body').on('click', '[data-dismiss="modal"]', function(e){
    $.addScrollingTouch();
  });

  $('body').on('click', '.state-trigger', function() {
    var element;
    element = $(this);
    if (element.data('swal')) {
      return swal({
        title: element.data('swal-title') || 'Are you sure?',
        text: element.data('swal-text') || '',
        type: element.data('swal-type') || 'warning',
        showCancelButton: true,
        confirmButtonClass: element.data('swal-confirm-btn-class') || 'btn-warning',
        confirmButtonText: 'Yes',
        cancelButtonText: 'No',
        closeOnConfirm: true,
        closeOnCancel: true
      }, function(isConfirm) {
        if (isConfirm) {
          return stateTriggerHandler(element);
        }
      });
    } else {
      return stateTriggerHandler(element);
    }
  });

  $('body').on('ajax:success', '.best_in_place[data-bip-attribute="fabric_state"]', function(e) {
    var url;
    url = $(this).attr('data-url');
    return $.ajax({
      type: 'GET',
      dataType: 'script',
      url: url
    });
  });

  $('body').on('click', '.close_modal_button', function(e) {
    $('.modal-backdrop.fade.in').hide();
  });

  $('body').on('click', '#state-error-submit-button', function(e) {
    e.preventDefault();
    var form = $(this).parents('.modal-content').find('#errorForm');
    var url = form.data('url');
    var method = form.data('method');
    var id = form.data('id');
    var state_event = form.data('state-event');
    var line_item_data = {};
    $(form.find('input, select, textarea')).each(function(index, obj){
        if ($(obj).is(':checkbox')) {
          line_item_data[obj.name] = $(obj).is(':checked')
        } else {
          line_item_data[obj.name] = obj.value;
        }
    });

    return $.ajax({
      type: method,
      dataType: 'json',
      url: url,
      data: {
        line_item: line_item_data
      },
      success: function(data) {
        var state;
        if ($('.vex').length) {
          state = $('#vex_line_item_' + id).find('a[data-state-event="' + state_event + '"]');
        } else {
          state = $('#line_item_' + id).find('a[data-state-event="' + state_event + '"]');
        };

        state.click();
        return $('#state-error-modal').modal('hide');
      },
      error: function(data) {
        $.each( data.responseJSON['errors'], function( key, value ) {
          input = $('#state-error-modal-body').find('#' + key)
          input.addClass('error_field');
          html = '<span class="error_text">' + value.join('; ') + '</span>'
          input.after(html)
        });
      }
    });
  });

  $('body').on('click', '#batch-state-error-submit-button', function(e) {
    e.preventDefault();

    var form = $(this).parents('.modal-content').find('#batchErrorForm');
    var url = form.data('url');
    var method = form.data('method');
    var ids = form.data('ids');
    var state_event = form.data('state-event');
    var line_items_data = {};

    $(form.find('input, select, textarea')).each(function(index, obj){
        line_items_data[obj.name] = obj.value;
    });

    return $.ajax({
      type: method,
      dataType: 'json',
      url: url,
      data: {
        ids: ids,
        event: state_event,
        attributes:
          line_items_data
      },
      success: function(data) {
        var state;
        state = $('.action_items').find('.batch-state-trigger[data-state-event="' + state_event + '"]');
        state.click();
        return $('#batch-state-error-modal').modal('hide');
      },
      error: function(data) {
        $('#batch-state-error-modal').modal('hide');
      }
    });
  });

  $('body').on('change', '.item-state-select', function(e) {
    var default_state, input, state, url;
    input = $(this);
    default_state = input.attr('data-default');
    url = input.attr('data-url');
    state = input.val();
    return swal({
      title: 'Are you sure you want to change state?',
      text: 'All your actions will be saved in state history',
      type: 'warning',
      showCancelButton: true,
      confirmButtonClass: 'btn-success',
      confirmButtonText: 'Change state',
      cancelButtonText: 'Cancel',
      closeOnConfirm: true,
      closeOnCancel: false
    }, function(isConfirm) {
      if (isConfirm) {
        return $.ajax({
          type: 'PATCH',
          dataType: 'script',
          url: url,
          data: {
            line_item: {
              state: state
            }
          },
          success: function() {
            return $.purrSuccess();
          }
        });
      } else {
        swal('Cancelled', 'State is not changed');
        return input.val(default_state);
      }
    });
  });

  $('body').on('click', '.state-button.delete', function(e) {
    var id, url;
    url = $(this).attr('data-url');
    id = $(this).attr('data-id');
    return swal({
      title: 'Are you sure you want to destroy this item?',
      text: 'You wont be able to get it back',
      type: 'error',
      showCancelButton: true,
      confirmButtonClass: 'btn-danger',
      confirmButtonText: 'Destroy',
      cancelButtonText: 'Cancel',
      closeOnConfirm: false,
      closeOnCancel: false
    }, function(isConfirm) {
      if (isConfirm) {
        return $.ajax({
          type: 'DELETE',
          dataType: 'json',
          url: url,
          success: function() {
            swal("Deleted!", "Your imaginary file has been deleted.", 'success');
            return $("#line_item_" + id).fadeOut(500, function() {
              return $("#line_item_" + id).remove();
            });
          }
        });
      } else {
        return swal('Cancelled', 'Item is safe');
      }
    });
  });

  $('body').on('click', '#refund-submit-button', function(e) {
    var amount, id, url, reason, comment;
    amount = $('#refund-amount').val();
    reason = $('#refund-reason').val();
    comment = $('#refund-comment').val();
    url = $('#refund-amount').attr('data-url');
    id = $('#refund-amount').attr('data-id');


    return $.ajax({
      type: 'PATCH',
      dataType: 'script',
      url: url,
      data: {
        refund: {
          amount: amount,
          reason: reason,
          comment: comment
        }
      }
    });
  });

  $('body').on('change', '#refund-reason', function(e) {
    if ($(this).val() == 'Other') {
      $('#refund-comment-group').removeClass('hidden')
    } else {
      $('#refund-comment-group').addClass('hidden')
    }
  });

  $('body').on('keypress', function(e) {
    var keyCode;
    keyCode = e.keyCode || e.which;
    if (e.keyCode === 13 && e.target.id === 'refunded-field') {
      e.preventDefault();
      return $('#refund-submit-button').click();
    }
  });

  return $('body').on('click', '.reorder-columns', function() {
    var state;
    if ($(this).attr('data-state') === 'off') {
      $(this).attr('data-state', 'on');
    } else {
      $(this).attr('data-state', 'off');
    }
    state = $(this).attr('data-state');
    $('.index_table').find('thead').find('th').each(function(i) {
      if (state === 'on') {
        return $(this).addClass('reordable');
      } else {
        return $(this).removeClass('reordable');
      }
    });
    if (state === 'on') {
      $(this).html('Stop');
    } else {
      $(this).html('Reorder');
    }
    return $('.index_table').dragtable({
      persistState: function(table) {
        table.el.find('th').each(function(i) {
          var text;
          text = $(this).text().replace(/(\r\n|\n|\r)/gm, "");
          text = text.replace(/\s/g, '');
          if (text === '' || text === 'Id') {
            return true;
          }
          return table.sortOrder[$(this).text()] = i - 1;
        });
        return $.ajax({
          type: 'PATCH',
          dataType: 'script',
          url: $('#reorder-url').attr('data-path'),
          data: {
            columns: table.sortOrder,
            scope: $('#reorder-url').attr('data-scope'),
            page: $('#reorder-url').attr('data-page')
          }
        });
      },
      beforeStart: function(table) {
        if (state === 'on') {
          return true;
        } else {
          return false;
        }
      },
      dragaccept: '.reordable'
    });
  });
});
