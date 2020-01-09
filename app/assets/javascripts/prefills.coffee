$(document).ready ->
  ids =
    neck:            ['shirt_neck', 'jacket_neck', 'overcoat_neck']
    chest:           ['shirt_chest', 'jacket_chest', 'overcoat_chest', 'waistcoat_waistcoat_chest']
    pant_waist:      ['pants_pant_waist', 'chinos_pant_waist']
    waist:           ['overcoat_waist', 'waistcoat_waistcoat_waist', 'shirt_waist_belly_button', 'jacket_waist_belly_button', 'waistcoat_waist_belly_button']
    button_position: ['jacket_waist_button_position', 'shirt_waist_button_position', 'waistcoat_waist_button_position']
    hip:             ['shirt_hip', 'jacket_hip', 'overcoat_hip', 'pants_hip_pants_no_pleats', 'chinos_hip_pants_no_pleats']
    hip_pants_with_pleats: ['pants_hip_pants_with_pleats', 'chinos_hip_pants_with_pleats']
    wrist:           ['shirt_wrist_cuff_button_cuff_without_watch', 'jacket_wrist_cuff']
    biceps:          ['shirt_biceps', 'jacket_biceps', 'overcoat_biceps']
    rise:            ['pants_rise', 'chinos_rise']
    thigh:           ['pants_thigh', 'chinos_thigh']
    knee:            ['pants_knee', 'chinos_knee']
    calf:            ['pants_calf', 'chinos_calf']
    cuff:            ['pants_pant_cuff', 'chinos_pant_cuff']
    length_outseam_left:   ['pants_pant_length_outseam_left_leg', 'pants_chino_outseam_left_leg',
                            'chinos_pant_length_outseam_left_leg', 'chinos_pant_length_outseam_right_leg',
                            'pants_pant_length_outseam_right_leg', 'pants_chino_outseam_right_leg']
    length_outseam_right:  ['pants_pant_length_outseam_right_leg', 'chinos_pant_length_outseam_left_leg',
                            'chinos_pant_length_outseam_right_leg', 'pants_chino_outseam_right_leg',
                            'pants_pant_length_outseam_left_leg', 'pants_chino_outseam_left_leg']
    length_outseam:  ['pants_pant_length_outseam', 'chinos_pant_length_outseam']
    shirt_sleeve:    ['shirt_shirt_sleeve_length_left_sleeve', 'shirt_shirt_sleeve_length_right_sleeve']
    jacket_sleeve:   ['jacket_jacket_sleeve_length_right_sleeve', 'jacket_jacket_sleeve_length_left_sleeve']
    overcoat_sleeve:   ['overcoat_overcoat_sleeve_length_left_sleeve', 'overcoat_overcoat_sleeve_length_right_sleeve']
    waistcoat_front: ['waistcoat_waistcoat_front_length_pointed', 'waistcoat_waistcoat_front_length_straight']

  which_array = (name) ->
    switch
      when name.indexOf("neck")                   != -1 then 'neck'
      when name.indexOf("chest")                  != -1 then 'chest'
      when name.indexOf("waist_button_position")  != -1 then 'button_position'
      when name.indexOf("pant_waist")             != -1 then 'pant_waist'
      when name.indexOf("waistcoat_front_length") != -1 then 'waistcoat_front'
      when name.indexOf("waist")                  != -1 then 'waist'
      when name.indexOf("hip_pants_with_pleats")  != -1 then 'hip_pants_with_pleats'
      when name.indexOf("hip")                    != -1 then 'hip'
      when name.indexOf("wrist")                  != -1 then 'wrist'
      when name.indexOf("biceps")                 != -1 then 'biceps'
      when name.indexOf("rise")                   != -1 then 'rise'
      when name.indexOf("thigh")                  != -1 then 'thigh'
      when name.indexOf("knee")                   != -1 then 'knee'
      when name.indexOf("calf")                   != -1 then 'calf'
      when name.indexOf("cuff")                   != -1 then 'cuff'
      when name.indexOf("length_outseam_left")    != -1 then 'length_outseam_left'
      when name.indexOf("length_outseam_right")   != -1 then 'length_outseam_right'
      when name.indexOf("length_outseam")         != -1 then 'length_outseam'
      when name.indexOf("shirt_sleeve_length")    != -1 then 'shirt_sleeve'
      when name.indexOf("jacket_sleeve_length")   != -1 then 'jacket_sleeve'
      when name.indexOf("overcoat_sleeve_length") != -1 then 'overcoat_sleeve'



  not_for_fill = (measurement) ->
    !measurement.length > 0 || parseFloat(measurement.val()) == 0.0

  $.prefill =
    check_prefill: (name, value) ->
      ids_name = which_array(name)
      $.prefill.fill(name, value, ids[ids_name])

    fill: (name, value, array) ->
      if $.inArray(name, array) != -1
        array =
          $.map array, (e) ->
            e if e != name

        $.each array, (index, loop_name) ->
          measurement = $('#measurement_' + loop_name)
          if measurement.length > 0
            readonly = measurement.prop('readonly')
            disabled = measurement.prop('disabled')

            return true if readonly || disabled || parseFloat(measurement.val()) == value

            measurement.val(value)
            $.prefill.setPrefillMessage(name, measurement)
            fit_name = loop_name.replace(/_.*/, '_fit')

            if loop_name in $.default_calculation_measurements
              $.calculations.default(measurement, loop_name, fit_name)
            else
              $.calculations[loop_name](measurement, loop_name, fit_name)

    prefill_post_alter_garment: ->
      $('.post-alteration-garment').each ->
        fill_value = $(this).val()
        name = $(this).attr('id')
        name = name.replace(/garment_/, '')
        ids_name = which_array(name)
        array = ids[ids_name]
        unchangeable_categories = document.getElementById('unchangeable_categories')
        unchangeable_categories_array = JSON.parse(unchangeable_categories.value)

        return true if $.inArray(name, array) == -1

        names_to_fill =
          $.map array, (e) ->
            e if e != name

        $.each names_to_fill, (index, name) ->
          loop_garment = $('#garment_' + name)
          return if Object.values(unchangeable_categories_array).includes(Number($(loop_garment).attr('data-category')))

          unless loop_garment.prop('disabled')
            loop_garment.val(fill_value).trigger('change')
            $.prefill.setPrefillMessage(name, loop_garment)

    check_for_selector: (selector) ->
      $(selector).each ->
        val = 0
        name = $(this).attr('id')
        filled_by_name = ''
        return true if name.indexOf("adjustment_") != -1
        measurement = $(this)
        name = name.replace(/measurement_/, '')
        ids_name = which_array(name)
        array = ids[ids_name]

        return true if $.inArray(name, array) == -1

        array =
          $.map array, (e) ->
            e if e != name

        $.each array, (index, name) ->
          loop_measurement = $('#measurement_' + name)
          return true if not_for_fill(loop_measurement)
          fill_value = parseFloat(loop_measurement.val())
          val = fill_value if val < fill_value
          filled_by_name = name

        unless measurement.prop('readonly') || measurement.prop('disabled')
          measurement.val(val)
          $.prefill.setPrefillMessage(filled_by_name, measurement) if val != 0
          fit_name = name.replace(/_.*/, '_fit')

          if name in $.default_calculation_measurements
            $.calculations.default(measurement, name, fit_name)
          else
            $.calculations[name](measurement, name, fit_name)

    setPrefillMessage: (name, measurement) ->
      $.prefill.clearPrefillMessage(measurement)

      filled_by_name = name.split('_')
      category = filled_by_name.splice(0,1).join(' ')
      parameter = filled_by_name.join(' ')

      measurement.closest('td').addClass('info-td-msg')
      measurement.closest('td').append("<span class='info-text-msg uppercase'><b>Autofill: </b>#{category} - #{parameter}</span>")

    clearPrefillMessage: (measurement) ->
      measurement.closest('td').removeClass('info-td-msg')
      measurement.closest('td').find('.info-text-msg').remove()
