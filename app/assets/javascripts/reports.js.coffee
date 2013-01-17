# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  $("#other_person").hide()
  $("input[name=person_select]").change ->
    if $("input[name=person_select]:checked").val()=="other"
      $("#other_person").show()
    else
      $("#other_person").hide()