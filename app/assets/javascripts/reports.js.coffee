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

intervalID = null

startProgressCheck = ->
  showProgressBar()
  disableProgressButton()
  intervalID = setInterval(checkProgress, 5000)

stopProgressCheck = ->
  clearInterval(intervalID)

checkProgress = ->
  $.getJSON('/reports/progress')
    .done((data, status) ->
      displayProgress(data.percent_complete)

      if data.percent_complete == 100
        stopProgressCheck()
        resetPorgressForm()
    )
    .fail( -> alert 'problem checking progress!' )

disableProgressButton = ->
  $('#Load').prop
    disabled: true
    value: 'Loading... 0%'

showProgressBar = ->
  $('#data_status').text('')
  displayProgress(0)
  $('#data_loaded').parent().show()

displayProgress = (percent_complete) ->
  $('#data_loaded').css('width', "#{percent_complete}%")
  $('#Load').prop('value', "Loading... #{percent_complete}%")

resetPorgressForm = ->
  $('#Load').prop
    disabled: false
    value: 'Reload Data'

  $('#data_status').text('Data loaded!')

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

    $.getJSON("../reports/build_detail_ped", root_person: jqroot_person)
      .done((data, status) ->
        startProgressCheck()
      )
      .fail((data, status) ->
        stopProgressCheck()
        alert 'failure!'
      )

$ ->
  $("#Run_Report").click ->
    if $("#type").val().length==0
      alert "Please select a report type."
      return false
    else
      $(this).closest('form').submit()
	  return false

