# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  $('body').on 'change', '.fits', ->
    unchangeable_categories = document.getElementById('unchangeable_categories')
    unchangeable_categories_array = JSON.parse(unchangeable_categories.value)
    $('.calculatable').each ->
      return if Object.values(unchangeable_categories_array).includes(Number($(this).attr('data-category')))
      $.calculations.general($(this))
