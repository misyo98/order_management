// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery.remotipart
//= require twitter/bootstrap
//= require select2
//= require jquery.previewimage
//= require fakeLoader.min.js
//= require sweetalert.min.js
//= require pusher.min.js
//= require bootstrap-datepicker/core
//= require cocoon
//= require active_bootstrap_skin
//= require active_admin/base
//= require bootstrap-sprockets
//= require_tree .

(function($) {
  $.fn.serializeFormJSON = function() {
    var formArray, response;
    response = {};
    formArray = this.serializeArray();
    $.each(formArray, function() {
      if (response[this.name]) {
        if (!response[this.name].push) {
          response[this.name] = [response[this.name]];
        }
        response[this.name].push(this.value || '');
      } else {
        response[this.name] = this.value || '';
      }
    });
    return response;
  };
})(jQuery);
