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
	  
# $ ->
#   $("#Load").click ->
#    $.get "reports/build_detail_controller", person_select: $("#person_select").val()
	
	
$ ->
  $("#Load").click ->
    if $("input[name=person_select]:checked").val() is "me"
      jqroot_person = $("input[name=person_select]:checked").val()
    else if $("input[name=person_select]:checked").val() is "other"
      if ($("#other_person_field").val().match(/^[a-zA-Z0-9]{4}[\-]{1}[a-zA-Z0-9]{3}$/))
        jqroot_person = $("#other_person_field").val()
      else 
        alert "Please enter a valid Personal Identifier for the root person of the report. (example: KQZZ-N2J)"
        $("#other_person_field").focus()
        return false
    $.get "../reports/build_detail_controller", root_person: jqroot_person, (data, status) ->
      alert data  if status is "success"

