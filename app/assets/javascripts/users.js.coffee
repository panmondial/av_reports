# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  $("#other_lead_source").hide()
  $("#user_lead_source").change ->
    if $("#user_lead_source").val()=="Other"
      $("#other_lead_source").show()
    else
      $("#other_lead_source").hide()
