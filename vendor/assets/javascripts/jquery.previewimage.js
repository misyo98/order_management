(function($) {
  $.fn.previewImage = function(holder, fit) {
    var BLOCK_SIZE = 223;
    $(this).on("change", function() {
      var files = !!this.files ? this.files : [];
      if (!files.length || !window.FileReader) return; // no file selected, or no FileReader support
      $(".progress_holder").show();
      if (/^image/.test( files[0].type)){ // only image file
        var reader = new FileReader(); // instance of the FileReader
        reader.readAsDataURL(files[0]); // read the local file

        reader.onload = function() { // set image data as background of div
          if (fit) {
            var per, h, w, margin, styles;
            $(holder).find('img').remove();
            $(holder).prepend("<img id='preview__image' style='display: none;' src='" + reader.result + "'/>");
            $( "#preview__image" ).load( function () {
              var imgWidth = $("#preview__image").width(), imgHeight = $("#preview__image").height();
              if (imgWidth > imgHeight) {
                per = BLOCK_SIZE / imgWidth;
                h = Math.round(imgHeight * per);
                margin = (BLOCK_SIZE - h) / 2;
                //styles = {'width' : '100%', 'height' : 'auto', 'margin-top': margin + 'px'}
                styles = 'width: 100%; height: auto; margin-top: ' + margin + 'px;';
              } else {
                per = BLOCK_SIZE / imgHeight;
                w = Math.round(imgWidth * per);
                margin = (BLOCK_SIZE - w) / 2;
                //styles = {'width': 'auto', 'height': '100%', 'margin-left': margin + 'px'}
                styles = 'width: auto; height: 100%; margin-left: ' + margin + 'px;'
              }
              //$(holder).find('img').css(styles);
              $(holder).prepend("<img style='" + styles + "' src='" + reader.result + "'/>");
            });
          } else {
            $(holder).css("background-image", "url("+this.result+")");
          }
        }

        reader.onprogress = function(data) {
          if (data.lengthComputable) {
            var progress = parseInt( ((data.loaded / data.total) * 100), 10 );
            //Progress bar
            $(".progress-bar").width(progress + '%');
            if (progress == 100) {
              $(".progress_holder").hide();
              $("#upload_finish").show();
              $("#upload_finish").fadeOut(200);
            }

          }
        }
      }
    });
  };
})(jQuery);
