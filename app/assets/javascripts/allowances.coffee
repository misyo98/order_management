$(document).ready ->

  $('body').on 'change', '.allowances', () ->
    return true if $(this).attr('readonly') || $(this).attr('disabled')
    name = $(this).attr('id')
    name = name.replace(/allowance_/, '')
    measurement = $('#measurement_' + name)
    allowance = $(this).val()

    $.calculations.general(measurement, allowance)