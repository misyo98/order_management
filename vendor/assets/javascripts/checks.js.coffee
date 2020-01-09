convertTo = (type, $this, input_id) ->
  inches = if type == 'cm'
    (parseFloat($this.val())*2.54).toFixed(2)
  else if type == 'inch'
    (parseFloat($this.val())/2.54).toFixed(2)
  else
    $this.val()
  
  $("#{input_id}").val(inches)

calcMeasurement = ($this) ->
  value = $this.val()
  id = $this.attr('id')
  name = $this.attr('name')

  $.methods.calculateChecks(value, id)
  $.methods.calculateAbsChecks(value, id)

$(document).ready ->
  $('body').on 'keyup', '.measurement_values', ->
    calcMeasurement($(this))

  $('body').on 'keyup', '#garment_height_height_inches', ->
    convertTo('cm', $(this), '#garment_height_height_cm')
    calcMeasurement($(this))

  $('body').on 'keyup', '#garment_height_height_cm', ->
    convertTo('inch', $(this), '#garment_height_height_inches')
    calcMeasurement($('#garment_height_height_inches'))

  $('body').on 'change', '.fits', ->
    elements = $("tr[data-category='#{$(this).data('category')}']")
    if $(this).is(':checked')
      elements.removeClass('hidden')
    else
      elements.addClass('hidden')
